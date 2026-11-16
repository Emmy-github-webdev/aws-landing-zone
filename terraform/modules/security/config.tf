
resource "aws_config_configuration_aggregator" "organization" {
  count = var.enable_config && var.enable_config_aggregator ? 1 : 0

  name = var.config_aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = var.config_aggregator_role_arn
  }

  lifecycle {
    precondition {
      condition = (
        local.config_role_account_id == var.security_account_id
      )

      error_message = "The AWS Config aggregator role must belong to the security account."
    }
  }

  tags = local.common_tags
}

resource "aws_organizations_aws_service_access" "config" {
  provider = aws.management

  service_principal = "config.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "config" {
  provider = aws.management

  account_id        = var.security_account_id
  service_principal = "config.amazonaws.com"

  depends_on = [
    aws_organizations_aws_service_access.config
  ]
}