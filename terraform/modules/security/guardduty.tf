
resource "aws_guardduty_detector" "security" {
  count = var.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = local.common_tags
}

resource "aws_guardduty_organization_configuration" "security" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.security[0].id

  auto_enable_organization_members = "ALL"
}

resource "aws_guardduty_organization_configuration_feature" "security" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.security[0].id
  name        = "S3_DATA_EVENTS"

  auto_enable = "ALL"
}
