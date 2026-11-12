terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"

      configuration_aliases = [
        aws.management,
        aws.logging,
        aws.secondary
      ]
    }
  }
}

# Security account - primary region
provider "aws" {
  region = var.primary_region

  assume_role {
    role_arn = var.security_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}

# Organizations management account
provider "aws" {
  alias  = "management"
  region = var.primary_region

  default_tags {
    tags = var.common_tags
  }
}

# Logging account
provider "aws" {
  alias  = "logging"
  region = var.primary_region

  assume_role {
    role_arn = var.logging_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}

# Security account - secondary region
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region

  assume_role {
    role_arn = var.security_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}
