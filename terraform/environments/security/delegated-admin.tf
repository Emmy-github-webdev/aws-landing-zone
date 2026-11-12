
# GuardDuty delegated administrator
resource "aws_guardduty_organization_admin_account" "security" {
  provider = aws.management

  admin_account_id = var.security_account_id
}

# Security Hub delegated administrator
resource "aws_securityhub_organization_admin_account" "security" {
  provider = aws.management

  admin_account_id = var.security_account_id
}

# Enable trusted access for IAM Access Analyzer
resource "aws_organizations_aws_service_access" "access_analyzer" {
  provider = aws.management

  service_principal = "access-analyzer.amazonaws.com"
}

# Register Security account as Access Analyzer delegated administrator
resource "aws_organizations_delegated_administrator" "access_analyzer" {
  provider = aws.management

  account_id        = var.security_account_id
  service_principal = "access-analyzer.amazonaws.com"

  depends_on = [
    aws_organizations_aws_service_access.access_analyzer
  ]
}
