output "egress_vpc_id" {
  description = "Egress VPC ID"
  value       = aws_vpc.egress.id
}

output "egress_firewall_arn" {
  value = ws_networkfirewall_firewall.egress.arn
}

output "ress_nat_public_ips" {
  value = aws_eip.egress_nat
}

output "egress_firewall_endpoint_ids" {
  value = aws_route.egress_tgw_to_firewall
}