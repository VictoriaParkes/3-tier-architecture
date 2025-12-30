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