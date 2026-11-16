
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"

      configuration_aliases = [
        aws.infrastructure,
        aws.production,
        aws.nonproduction,
        aws.logging
      ]
    }
  }
}

provider "aws" {
  alias  = "infrastructure"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${local.infrastructure_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "production"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${local.production_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "nonproduction"
  region = var.primary_region

  assume_role {
    role_arn = "arn:aws:iam::${local.nonproduction_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "logging"
  region = var.primary_region

}