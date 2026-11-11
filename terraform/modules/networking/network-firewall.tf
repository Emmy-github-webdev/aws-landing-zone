
resource "aws_networkfirewall_firewall" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  name                = "lz-central-egress-firewall"
  description         = "Centralized AWS Landing Zone egress inspection"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.egress[0].arn
  vpc_id              = aws_vpc.egress[0].id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.egress_firewall

    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  delete_protection                 = true
  firewall_policy_change_protection = true
  subnet_change_protection          = true

  tags = merge(
    local.common_tags,
    {
      Name    = "lz-central-egress-firewall"
      Purpose = "OutboundTrafficInspection"
    }
  )

  depends_on = [
    aws_subnet.egress_firewall
  ]
}
