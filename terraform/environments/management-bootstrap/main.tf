# Enable trusted access
resource "aws_organizations_aws_service_access" "guardduty" {
  provider = aws.management

  service_principal = "guardduty.amazonaws.com"
}

# GuardDuty detector - management account primary region
resource "aws_guardduty_detector" "management_primary" {
  provider = aws.management

  enable = true
}

# GuardDuty detector - management account secondary region
resource "aws_guardduty_detector" "management_secondary" {
  provider = aws.management_secondary

  enable = true
}

resource "aws_guardduty_organization_admin_account" "security_primary" {
  provider = aws.management

  admin_account_id = var.security_account_id

  depends_on = [
    aws_organizations_aws_service_access.guardduty,
    aws_guardduty_detector.management_primary
  ]
}

resource "aws_guardduty_organization_admin_account" "security_secondary" {
  provider = aws.management_secondary

  admin_account_id = var.security_account_id

  depends_on = [
    aws_organizations_aws_service_access.guardduty,
    aws_guardduty_detector.management_secondary
  ]
}