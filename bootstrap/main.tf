
resource "aws_controltower_landing_zone" "main" {
  manifest_json = file(
    "${path.module}/landing-zone-manifest.json"
  )

  # Use a supported Control Tower landing zone version.
  # Confirm the version available in your home Region.
  version = var.control_tower_version

  tags = {
    Name        = "company-landing-zone"
    Environment = "Foundation"
    ManagedBy   = "Terraform"
  }

  timeouts {
    create = "180m"
    update = "180m"
    delete = "180m"
  }

  depends_on = [
    aws_organizations_organization.main,
    aws_organizations_organizational_unit.security,
    aws_organizations_account.audit,
    aws_organizations_account.log_archive
  ]
}
