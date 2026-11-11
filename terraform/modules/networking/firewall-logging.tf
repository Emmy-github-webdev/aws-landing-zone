
resource "aws_cloudwatch_log_group" "firewall_flow" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  name              = "/aws/network-firewall/landing-zone/flow"
  retention_in_days = var.firewall_log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "firewall_alert" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  name              = "/aws/network-firewall/landing-zone/alert"
  retention_in_days = var.firewall_log_retention_days

  tags = local.common_tags
}

resource "aws_networkfirewall_logging_configuration" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.egress[0].arn

  logging_configuration {
    log_destination_config {
      log_type = "FLOW"

      log_destination_type = "CloudWatchLogs"

      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow[0].name
      }
    }

    log_destination_config {
      log_type = "ALERT"

      log_destination_type = "CloudWatchLogs"

      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert[0].name
      }
    }
  }
}
