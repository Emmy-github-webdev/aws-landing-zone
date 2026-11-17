output "egress_vpc_id" {
  description = "Egress VPC ID"
  value       = try(aws_vpc.egress[0].id, null)
}

output "egress_firewall_arn" {
  value = try(aws_networkfirewall_firewall.egress[0].arn, null)
}

output "egress_nat_public_ips" {
  value = aws_eip.egress_nat
}

output "egress_firewall_endpoint_ids" {
  value = local.firewall_endpoint_ids
}