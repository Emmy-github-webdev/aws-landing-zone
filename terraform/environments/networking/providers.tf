
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"

      configuration_aliases = [
        aws.infrastructure,
        aws.production,
        aws.nonproduction
      ]
    }
  }
}

provider "aws" {
  alias  = "infrastructure"
  region = var.primary_region

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "production"
  region = var.primary_region

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "nonproduction"
  region = var.primary_region

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "logging"
  region = var.primary_region

}