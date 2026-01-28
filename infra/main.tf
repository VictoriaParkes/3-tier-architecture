# the primary Terraform configuration file that defines your infrastructure as
# code. It serves as the blueprint for creating and managing cloud resources.

# Configure AWS as cloud provider
provider "aws" {
  region = var.region # set the region as defined in variables.tf
}

# Container Registry
# Create an ECR repository to store application images
resource "aws_ecr_repository" "ecr" {
  name                 = var.ecr_name # name the repository
  image_tag_mutability = "IMMUTABLE" # Don't allow image tag updates

  # Enable security scanning on image uploads
  image_scanning_configuration {
    scan_on_push = true
  }
}

# VPC Network
# Creates isolated network across 3 availability zones
module "vpc" {
  source = "terraform-aws-modules/vpc/aws" # official AWS VPC module from Terraform Registry

  name = var.vpc_name # name the VPC
  cidr = var.vpc_cidr # Define CIDR range

  azs             = var.availability_zones
  private_subnets = var.private_subnets_cidr # Private subnets for secure app hosting
  public_subnets  = var.public_subnets_cidr # Public subnets for load balancers

  enable_nat_gateway = true # NAT gateways for outbound internet access
  enable_vpn_gateway = true # VPN gateway for secure encrypted connection between VPC and external networks

  tags = {
    Terraform   = "true" # tag resource as created by Terraform (not manually via AWS console)
    Environment = "dev" # tag as development environment resource (vs staging/prod)
  }
}

# Provision EKS cluster for container orchestration using a pre-built Terraform module
module "eks" {
  source  = "terraform-aws-modules/eks/aws" # official AWS EKS module from Terraform Registry
  version = "21.8.0" # Pin to specific module version for consistency

  name               = var.cluster_name # name the cluster
  kubernetes_version = var.kubernetes_version # set K8 version for consistency

  # Essential addons for networking and security
  addons = {
    coredns = {} # DNS service for pod-to-pod communication
    eks-pod-identity-agent = {
      before_compute = true
    } # Manages IAM roles for pods (installed before nodes)
    kube-proxy = {} # Network proxy for service load balancing
    vpc-cni = {
      before_compute = true
    } # AWS networking plugin (installed before nodes)
  }
  # "Key Feature:
  # before_compute = true  ensures networking and identity services are ready before worker nodes
  # join the cluster, preventing the NodeCreationFailure issues experienced earlier.
  # This creates the Kubernetes control plane that will orchestrate the containerized applications
  # across the VPC defined above."

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id # Connect EKS cluster to the VPC network
  subnet_ids = module.vpc.private_subnets # Run on private subnets for security

  /*
  # Explicit access entry
  # confilcts with enable_cluster_creator_admin_permissions
  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = data.aws_caller_identity.current.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  */

  # Two node groups with auto-scaling (1-5 total nodes)
  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.small"]
      desired_size   = 2
      max_size       = 3
      min_size       = 1
    }

    two = {
      name           = "node-group-2"
      instance_types = ["t3.small"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
    }
  }
}

# Get the current AWS account for permissions
data "aws_caller_identity" "current" {}

# Architecture Flow:

# Data Tier: Applications store container images in ECR

# Application Tier: Backend services run as pods in EKS private subnets

# Presentation Tier: Frontend/load balancers expose services via public subnets

# This creates a production-ready, scalable, and secure containerized application platform.


######################
# Jenkins EC2 config #
######################

# Prefix security group

resource "aws_security_group" "prefix_sg" {
  name = "prefix-security-group"
  description = "Allow HTTP traffic to load balancer"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "prefix-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "prefix_ingress_rule" {
  security_group_id = aws_security_group.prefix_sg.id

  prefix_list_id = "pl-fca24795"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "preffix_egress_rule" {
  security_group_id = aws_security_group.prefix_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Jenkins instance security group

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins-security-group"
  description = "Allow traffic from load balancer security group to jenkins instance"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "jenkins-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ingress_rule" {
  security_group_id = aws_security_group.jenkins_sg.id
  
  referenced_security_group_id = aws_security_group.prefix_sg.id
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "jenkins_egress_rule" {
  security_group_id = aws_security_group.jenkins_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# public subnet for load balancer

resource "aws_subnet" "LB_subnet_01" {
  vpc_id = module.vpc.vpc_id
  cidr_block = var.LB_subnet_cidr[0]
  availability_zone = var.jenkins_AZ

  tags = {
    Name = "public-LB-subnet-01"
  }
}

resource "aws_subnet" "LB_subnet_02" {
  vpc_id = module.vpc.vpc_id
  cidr_block = var.LB_subnet_cidr[1]
  availability_zone = module.vpc.azs[1]

  tags = {
    Name = "public-LB-subnet-02"
  }
}

# private subnet for jenkins instance
resource "aws_subnet" "jenkins_subnet" {
  vpc_id = module.vpc.vpc_id
  cidr_block = var.jenkins_subnet_cidr
  availability_zone = var.jenkins_AZ

  tags = {
    Name = "private-Jenkins-subnet"
  }
}

# jenkins instance
resource "aws_instance" "jenkins_ec2" {
  subnet_id = aws_subnet.jenkins_subnet.id
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<html><h1>Server 1</h1></html>" > /usr/share/nginx/html/index.html
  EOF
  )

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_route_table" "public_RT" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.igw_id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "pub_sub_route_01" {
  subnet_id = aws_subnet.LB_subnet_01.id
  route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "pub_sub_route_02" {
  subnet_id = aws_subnet.LB_subnet_02.id
  route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table" "private_RT" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = module.vpc.natgw_ids[0]
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "prv_sub_route" {
  subnet_id = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.private_RT.id
}

resource "aws_lb" "jenkins_alb" {
  load_balancer_type = "application"
  name = "jenkins-alb"
  internal = false
  
  subnets = [aws_subnet.LB_subnet_01.id, aws_subnet.LB_subnet_02.id]
  security_groups = [aws_security_group.prefix_sg.id]

  tags = {
    Name = "jenkins-alb"
  }
}

resource "aws_lb_target_group" "jenkins_alb_target_group" {
  name = "jenkins-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "jenkins_alb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_alb_target_group.arn
  target_id = aws_instance.jenkins_ec2.id
  port = 80
}

resource "aws_lb_listener" "jenkins_alb_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    
    forward {
      target_group {
        arn = aws_lb_target_group.jenkins_alb_target_group.arn
      }
    }
  }
}
