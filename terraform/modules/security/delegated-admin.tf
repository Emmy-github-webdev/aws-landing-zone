import {
  to = aws_guardduty_organization_admin_account.security[0]
  id = var.security_account_id
}

import {
  to = aws_securityhub_organization_admin_account.security[0]
  id = var.security_account_id
}

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

resource "aws_organizations_delegated_administrator" "access_analyzer" {
  count = var.enable_access_analyzer ? 1 : 0

  provider = aws.management

  account_id        = var.security_account_id
  service_principal = "access-analyzer.amazonaws.com"
}