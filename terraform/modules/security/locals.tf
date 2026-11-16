locals {
  common_tags = merge(
    var.policy_tags,
    {
      Environment  = var.environment
      ManagedBy    = "Terraform"
      Organization = var.organization_id
    }
  )

  is_primary_region = data.aws_region.current.region == var.primary_region

  security_services = {
    guardduty       = var.enable_guardduty
    securityhub     = var.enable_securityhub
    access_analyzer = var.enable_access_analyzer
    config          = var.enable_config
  }

  enable_regional_organization_services = (
    local.is_primary_region &&
    var.enable_access_analyzer
  )
}

locals {
  config_role_account_id = split(
    ":",
    var.config_aggregator_role_arn
  )[4]
}