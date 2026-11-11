#  Add organization validation to protects against accidentally deploying governance policies to the wrong organization
data "aws_organizations_organization" "current" {}
