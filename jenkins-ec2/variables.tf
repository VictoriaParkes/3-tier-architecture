variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "jenkins"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-2"
}

variable "jenkins_availability_zone" {
  description = "Availabilty zones"
  type        = string
  default     = "eu-west-2a"
}

data "aws_vpc" "existing_vpc" {
    filter {
        name = "tag:Name"
        values = ["blog-vpc"]
    }
}

# variable "infra-vpc" {
#     description = "Existing VPC"
#     default = 
# }

variable "jenkins_subnet_cidr" {
  description = "Public subnet CIDR blocks"
  type        = string
  default     = "10.0.7.0/24"
}