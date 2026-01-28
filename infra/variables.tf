# Define input parameters that make the Terraform configuration flexible and reusable.

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "ecr_name" {
  description = "Name of ECR repo"
  type        = string
  default     = "blog-repo"
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "blog-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availabilty zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "private_subnets_cidr" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets_cidr" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = "blog-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "LB_subnet_cidr" {
  description = "Load balancer subnet CIDR block"
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.8.0/24"]
}

variable "jenkins_subnet_cidr" {
  description = "Jenkins subnet CIDR block"
  type        = string
  default     = "10.0.9.0/24"
}

variable "jenkins_AZ" {
  description = "AZ jenkins server hosted"
  type = string
  default = "eu-west-2a"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# ^ This code is a data source that dynamically queries AWS to find an AMI (Amazon Machine Image) instead of hardcoding a specific AMI ID.

# Breaking it down:
# - data "aws_ami" - Queries AWS for AMI information
# - "amazon_linux_2023" - Local name to reference this AMI in your Terraform code

# Parameters:
# - most_recent = true - Gets the newest AMI that matches the filters (ensures you get the latest patches)
# - owners = ["amazon"] - Only searches AMIs published by Amazon (not third-party)

# Filters narrow down the search:
# - Name filter: "al2023-ami-*-kernel-6.1-x86_64"

#     - al2023-ami-* - Amazon Linux 2023 AMIs
#     - kernel-6.1 - Specifically kernel version 6.1
#     - x86_64 - 64-bit Intel/AMD architecture
#     - * is a wildcard for version numbers

# Virtualization filter: "hvm"
# - Hardware Virtual Machine (modern virtualization, required for most instance types)
# - Result: This automatically finds the latest Amazon Linux 2023 AMI with kernel 6.1 in your region, so you don't need to manually look up and update AMI IDs when new versions are released.
# - You reference it in your EC2 instance as: ami = data.aws_ami.amazon_linux_2023.id
