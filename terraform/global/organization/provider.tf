terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-banking-landing-zone"
      Environment = "global"
      ManagedBy   = "Terraform"
      Compliance  = "Banking"
    }
  }
}