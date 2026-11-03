# SECURITY OU
# Created by Control Tower during initial setup.
# Reference the existing OU rather than recreating it.

data "aws_organizations_organizational_units" "security" {
  parent_id = local.root_id
}

locals {
  security_ou_id = one([
    for ou in data.aws_organizations_organizational_units.security.children :
    ou.id if ou.name == "Security"
  ])
}

# INFRASTRUCTURE OU

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = local.root_id

  tags = {
    Purpose = "Infrastructure"
  }
}

# WORKLOADS OU

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.root_id

  tags = {
    Purpose = "Workloads"
  }
}

# PRODUCTION OU

resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Environment = "Production"
  }
}

# NON-PRODUCTION OU

resource "aws_organizations_organizational_unit" "non_production" {
  name      = "Non-Production"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Environment = "Non-Production"
  }
}

# SANDBOX OU

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = local.root_id

  tags = {
    Purpose = "Sandbox"
  }
}