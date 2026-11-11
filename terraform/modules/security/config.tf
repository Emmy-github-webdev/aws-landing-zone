
resource "aws_config_configuration_aggregator" "organization" {
  count = var.enable_config && var.enable_config_aggregator ? 1 : 0

  name = var.config_aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = var.config_aggregator_role_arn
  }

  tags = local.common_tags
}
