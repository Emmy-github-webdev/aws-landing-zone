data "aws_caller_identity" "security" {}

data "aws_caller_identity" "management" {
  provider = aws.management
}

data "aws_caller_identity" "logging" {
  provider = aws.logging
}

data "aws_organizations_organization" "current" {
  provider = aws.management
}

data "aws_region" "current" {}

