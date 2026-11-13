
# # GuardDuty delegated administrator
# # Enable trusted access for GuardDuty
# resource "aws_organizations_aws_service_access" "guardduty" {
#   provider = aws.management

#   service_principal = "guardduty.amazonaws.com"
# }

# # GuardDuty - primary region
# resource "aws_guardduty_organization_admin_account" "security_primary" {
#   provider = aws.management

#   admin_account_id = var.security_account_id
#   depends_on = [
#     aws_organizations_aws_service_access.guardduty
#   ]
# }

# # GuardDuty - secondary region
# resource "aws_guardduty_organization_admin_account" "security_secondary" {
#   provider = aws.management_secondary

#   admin_account_id = var.security_account_id
#   depends_on = [
#     aws_organizations_aws_service_access.guardduty
#   ]
# }

# # Security Hub delegated administrator
# # Security Hub - primary region
# resource "aws_securityhub_organization_admin_account" "security_primary" {
#   provider = aws.management

#   admin_account_id = var.security_account_id
# }

# # Security Hub - secondary region
# resource "aws_securityhub_organization_admin_account" "security_secondary" {
#   provider = aws.management_secondary

#   admin_account_id = var.security_account_id
# }

# # Enable trusted access for IAM Access Analyzer
# resource "aws_organizations_aws_service_access" "access_analyzer" {
#   provider = aws.management

#   service_principal = "access-analyzer.amazonaws.com"
# }

# # Register Security account as Access Analyzer delegated administrator
# resource "aws_organizations_delegated_administrator" "access_analyzer" {
#   provider = aws.management

#   account_id        = var.security_account_id
#   service_principal = "access-analyzer.amazonaws.com"

#   depends_on = [
#     aws_organizations_aws_service_access.access_analyzer
#   ]
# }

# resource "aws_iam_service_linked_role" "access_analyzer" {
#   provider = aws.management

#   aws_service_name = "access-analyzer.amazonaws.com"
# }


# ============================================================
# GuardDuty delegated administrator
# ============================================================

# Enable trusted access
resource "aws_organizations_aws_service_access" "guardduty" {
  provider = aws.management

  service_principal = "guardduty.amazonaws.com"
}

# Primary region
resource "aws_guardduty_organization_admin_account" "security_primary" {
  provider = aws.management

  admin_account_id = var.security_account_id

  depends_on = [
    aws_organizations_aws_service_access.guardduty
  ]
}

# Secondary region
resource "aws_guardduty_organization_admin_account" "security_secondary" {
  provider = aws.management_secondary

  admin_account_id = var.security_account_id

  depends_on = [
    aws_organizations_aws_service_access.guardduty
  ]
}


# ============================================================
# Security Hub delegated administrator
# ============================================================
resource "aws_guardduty_organization_admin_account" "security" {
  provider = aws.management

  admin_account_id = var.security_account_id
}

# Primary region
resource "aws_securityhub_organization_admin_account" "security_primary" {
  provider = aws.management

  admin_account_id = var.security_account_id
}

# Secondary region
resource "aws_securityhub_organization_admin_account" "security_secondary" {
  provider = aws.management_secondary

  admin_account_id = var.security_account_id
}


# ============================================================
# IAM Access Analyzer delegated administrator
# ============================================================

resource "aws_organizations_aws_service_access" "access_analyzer" {
  provider = aws.management

  service_principal = "access-analyzer.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "access_analyzer" {
  provider = aws.management

  account_id        = var.security_account_id
  service_principal = "access-analyzer.amazonaws.com"

  depends_on = [
    aws_organizations_aws_service_access.access_analyzer
  ]
}

resource "aws_iam_service_linked_role" "access_analyzer" {
  provider = aws.management

  aws_service_name = "access-analyzer.amazonaws.com"
}
