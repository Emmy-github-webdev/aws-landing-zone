
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"
    }
  }
}

provider "aws" {
  alias  = "infrastructure"
  region = var.primary_region

  assume_role {
    role_arn = var.infrastructure_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "production"
  region = var.primary_region

  assume_role {
    role_arn = var.production_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "nonproduction"
  region = var.primary_region

  assume_role {
    role_arn = var.nonproduction_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "logging"
  region = var.primary_region

  assume_role {
    role_arn = var.logging_role_arn
  }
}