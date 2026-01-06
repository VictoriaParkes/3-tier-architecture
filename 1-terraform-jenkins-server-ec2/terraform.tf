# Define the required providers in infrastructure
# Specify which external plugins Terraform needs to manage

# Terraform-specific settings
terraform {
  # Declare AWS provider as a dependency
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Points to the official AWS provider from HashiCorp's registry
      version = "6.19.0"        # Specifies the version of the provider to use
    }
  }
}

# Ensures all team members use the same AWS provider version
# Prevents breaking changes from automatic provider updates
# This is typically the first file Terraform reads when running terraform init,
# downloads the specified AWS provider plugin to manage cloud infrastructure.