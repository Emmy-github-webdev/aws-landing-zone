provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "AWS-Landing-Zone"
      ManagedBy = "Terraform"
      Purpose   = "Terraform-State"
    }
  }
}