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
  enable_vpn_gateway = false # VPN gateway for secure encrypted connection between VPC and external networks

  tags = {
    Terraform   = "true" # tag resource as created by Terraform (not manually via AWS console)
    Environment = "dev" # tag as development environment resource (vs staging/prod)
  }
}

# Provision EKS cluster for container orchestration using a pre-built Terraform module
module "eks" {
  source  = "terraform-aws-modules/eks/aws" # official AWS EKS module from Terraform Registry
  version = "~> 21.0" # Pin to specific module version for consistency

  name               = var.cluster_name # name the cluster
  kubernetes_version = var.kubernetes_version # set K8 version for consistency

  # Disable CloudWatch logging
  create_cloudwatch_log_group = false

  endpoint_public_access = true

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








# Jenkins IAM Role for Service Account (IRSA)
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach ECR permissions to Jenkins role
resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Custom policy for EKS operations
resource "aws_iam_role_policy" "jenkins_eks_policy" {
  name = "jenkins-eks-policy"
  role = aws_iam_role.jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "time_sleep" "wait_for_cluster" {
  depends_on = [module.eks.eks_managed_node_groups]
  create_duration = "30s"
}

# Jenkins Kubernetes Resources
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_role.arn
    }
  }
  depends_on = [kubernetes_namespace.jenkins]
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  spec {
    selector = {
      app = "jenkins"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
    port {
      name        = "agent"
      port        = 50000
      target_port = 50000
    }
    type = "LoadBalancer"
  }
  depends_on = [kubernetes_deployment.jenkins]
}

resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins-pvc"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  depends_on = [
    kubernetes_namespace.jenkins,
  ]
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.jenkins.metadata[0].name
        container {
          name  = "jenkins"
          image = "jenkins/jenkins:lts"
          port {
            container_port = 8080
          }
          port {
            container_port = 50000
          }
          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }
          volume_mount {
            name       = "jenkins-storage"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "jenkins-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_persistent_volume_claim.jenkins_pvc,
    kubernetes_service_account.jenkins
  ]
}
