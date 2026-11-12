
resource "aws_securityhub_account" "security" {
  count = var.enable_securityhub ? 1 : 0

  enable_default_standards = false

  auto_enable_controls = true

  control_finding_generator = "SECURITY_CONTROL"

}

resource "aws_securityhub_organization_configuration" "security" {
  count = var.enable_securityhub ? 1 : 0

  auto_enable = true

  depends_on = [
    aws_securityhub_account.security
  ]
}
