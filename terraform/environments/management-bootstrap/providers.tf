terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"

      configuration_aliases = [
        aws.management
      ]
    }
  }
}

provider "aws" {
  alias  = "management"
  region = var.primary_region
}

provider "aws" {
  alias  = "management_secondary"
  region = var.secondary_region
}