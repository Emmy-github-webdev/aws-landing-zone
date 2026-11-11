# Discover existing AWS Organization
data "aws_organizations_organization" "current" {}

# Discover existing root
data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# Discover Security OU
data "aws_organizations_organizational_unit" "security" {
  parent_id = data.aws_organizations_organization.current.roots[0].id
  name      = var.security_ou_name
}

# Discover Sandbox OU
data "aws_organizations_organizational_unit" "sandbox" {
  parent_id = data.aws_organizations_organization.current.roots[0].id
  name      = var.sandbox_ou_name
}