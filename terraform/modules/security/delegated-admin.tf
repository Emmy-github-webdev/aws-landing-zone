
resource "aws_guardduty_organization_admin_account" "security" {
  provider = aws.management

  count = var.enable_guardduty ? 1 : 0

  admin_account_id = var.security_account_id
}

resource "aws_securityhub_organization_admin_account" "security" {
  provider = aws.management

  count = var.enable_securityhub ? 1 : 0

  admin_account_id = var.security_account_id
}
