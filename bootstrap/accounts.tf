
# ==========================================================
# AWS ORGANIZATION
# ==========================================================

resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]

  lifecycle {
    prevent_destroy = true
  }
}

# ==========================================================
# SECURITY ORGANIZATIONAL UNIT
# ==========================================================

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id

  lifecycle {
    prevent_destroy = true
  }
}

# ==========================================================
# AUDIT ACCOUNT
# ==========================================================

resource "aws_organizations_account" "audit" {
  name      = "Audit"
  email     = var.audit_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  close_on_deletion = false

  tags = {
    Purpose    = "Security"
    Account    = "Audit"
    ManagedBy  = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ==========================================================
# LOG ARCHIVE ACCOUNT
# ==========================================================

resource "aws_organizations_account" "log_archive" {
  name      = "Log Archive"
  email     = var.log_archive_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  close_on_deletion = false

  tags = {
    Purpose    = "Logging"
    Account    = "LogArchive"
    ManagedBy  = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}
