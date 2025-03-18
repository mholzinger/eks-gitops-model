terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5" # Use the latest compatible version
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2" # Use the latest compatible version
    }
  }
  required_version = ">= 1.3.0" # Ensure Terraform version compatibility
}

provider "aws" {
  region = var.aws_region
}
