resource "aws_organizations_account" "infrastructure" {
  name      = "Infrastructure"
  email     = var.infrastructure_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  role_name = "OrganizationAccountAccessRole"

  close_on_deletion = true # set to false for production

  tags = var.policy_tags

  lifecycle {
    ignore_changes  = [role_name]
    prevent_destroy = false # Set to true for production. This is a test.
  }
}

resource "aws_organizations_account" "workloads" {
  name      = "Workloads"
  email     = var.workloads_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id

  role_name = "OrganizationAccountAccessRole"

  close_on_deletion = true # Set to false for production

  tags = var.policy_tags

  lifecycle {
    ignore_changes  = [role_name]
    prevent_destroy = false # Set to true for production. This is a test.
  }
}

resource "aws_organizations_account" "production" {
  name      = "Production"
  email     = var.production_account_email
  parent_id = aws_organizations_organizational_unit.production.id

  role_name = "OrganizationAccountAccessRole"

  close_on_deletion = true # Set to false for production

  tags = var.policy_tags

  lifecycle {
    ignore_changes  = [role_name]
    prevent_destroy = false # Set to true for production. This is a test.
  }
}

resource "aws_organizations_account" "nonproduction" {
  name      = "NonProduction"
  email     = var.nonproduction_account_email
  parent_id = aws_organizations_organizational_unit.nonproduction.id

  role_name = "OrganizationAccountAccessRole"

  close_on_deletion = true # Set to false for production

  tags = var.policy_tags

  lifecycle {
    ignore_changes  = [role_name]
    prevent_destroy = false # Set to true for production. This is a test.
  }
}