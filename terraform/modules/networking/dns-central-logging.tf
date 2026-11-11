resource "aws_cloudwatch_log_subscription_filter" "dns_infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name            = "lz-central-dns-subscription"
  log_group_name  = aws_cloudwatch_log_group.dns_infrastructure[0].name
  destination_arn = aws_cloudwatch_log_destination.central_dns.arn
  filter_pattern  = ""

  distribution = "Random"

  depends_on = [
    aws_cloudwatch_log_destination_policy.central_dns
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "dns_production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name            = "lz-central-dns-subscription"
  log_group_name  = aws_cloudwatch_log_group.dns_production[0].name
  destination_arn = aws_cloudwatch_log_destination.central_dns.arn
  filter_pattern  = ""

  distribution = "Random"

  depends_on = [
    aws_cloudwatch_log_destination_policy.central_dns
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "dns_nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name            = "lz-central-dns-subscription"
  log_group_name  = aws_cloudwatch_log_group.dns_nonproduction[0].name
  destination_arn = aws_cloudwatch_log_destination.central_dns.arn
  filter_pattern  = ""

  distribution = "Random"

  depends_on = [
    aws_cloudwatch_log_destination_policy.central_dns
  ]
}