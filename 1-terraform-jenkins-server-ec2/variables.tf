# variable "vpc_cidr_block" {}
# variable "subnet_cidr_block" {}
# variable "avail_zone" {}
# variable "env_prefix" {}
# variable "instance_type" {}


# variables.tf
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "jenkins-alb"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["pl-d3bc5fba"]  # Restricted to sg prefix list
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

# variable "acm_certificate_arn" {
#   description = "ARN of ACM certificate for HTTPS listener"
#   type        = string
# }

variable "use_cognito_auth" {
  description = "Use Cognito authentication (true) or OIDC (false)"
  type        = bool
  default     = true
}

# OIDC Variables (only needed if use_cognito_auth = false)
variable "oidc_authorization_endpoint" {
  description = "OIDC authorization endpoint"
  type        = string
  default     = ""
}

variable "oidc_client_id" {
  description = "OIDC client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "oidc_client_secret" {
  description = "OIDC client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "oidc_issuer" {
  description = "OIDC issuer URL"
  type        = string
  default     = ""
}

variable "oidc_token_endpoint" {
  description = "OIDC token endpoint"
  type        = string
  default     = ""
}

variable "oidc_user_info_endpoint" {
  description = "OIDC user info endpoint"
  type        = string
  default     = ""
}
