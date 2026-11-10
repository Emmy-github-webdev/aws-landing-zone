
locals {
  common_tags = merge(
    var.policy_tags,
    {
      Environment  = var.environment
      ManagedBy    = "Terraform"
      Organization = var.organization_id
    }
  )

  is_primary_region = data.aws_region.current.name == var.primary_region

  security_services = {
    guardduty       = var.enable_guardduty
    securityhub     = var.enable_securityhub
    access_analyzer = var.enable_access_analyzer
    config          = var.enable_config
  }
}
