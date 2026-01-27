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