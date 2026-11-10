
# Primary region security deployment

module "security_primary" {
  source = "../../modules/security"

  providers = {
    aws            = aws
    aws.management = aws.management
    aws.logging    = aws.logging
  }

  organization_id       = var.organization_id
  management_account_id = local.management_account_id
  security_account_id   = var.security_account_id
  logging_account_id    = var.logging_account_id

  approved_regions = var.approved_regions
  primary_region   = var.primary_region

  enable_guardduty       = true
  enable_securityhub     = true
  enable_access_analyzer = true
  enable_config          = true

  enable_cloudtrail        = true
  enable_config_aggregator = true

  config_aggregator_role_arn = var.config_aggregator_role_arn

  environment = var.environment
  policy_tags = var.common_tags
}

# Secondary region security deployment

module "security_secondary" {
  source = "../../modules/security"

  providers = {
    aws            = aws.secondary
    aws.management = aws.management
    aws.logging    = aws.logging
  }

  organization_id       = var.organization_id
  management_account_id = local.management_account_id
  security_account_id   = var.security_account_id
  logging_account_id    = var.logging_account_id

  approved_regions = var.approved_regions
  primary_region   = var.primary_region

  enable_guardduty       = true
  enable_securityhub     = true
  enable_access_analyzer = true
  enable_config          = false

  enable_cloudtrail        = false
  enable_config_aggregator = false

  config_aggregator_role_arn = var.config_aggregator_role_arn

  environment = var.environment
  policy_tags = var.common_tags
}
