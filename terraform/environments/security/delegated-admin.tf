resource "aws_guardduty_organization_admin_account" "security" {
  provider = aws.management

  admin_account_id = var.security_account_id
}

resource "aws_securityhub_organization_admin_account" "security" {
  provider = aws.management

  admin_account_id = var.security_account_id
}

# Enable AWS Organizations service access
resource "aws_organizations_aws_service_access_principal" "access_analyzer" {
  provider = aws.management

  service_principal = "access-analyzer.amazonaws.com"
}

# Register Security as delegated administrator
resource "aws_organizations_delegated_administrator" "access_analyzer" {
  provider = aws.management

  account_id        = var.security_account_id
  service_principal = "access-analyzer.amazonaws.com"

  depends_on = [
    aws_organizations_aws_service_access_principal.access_analyzer
  ]
}