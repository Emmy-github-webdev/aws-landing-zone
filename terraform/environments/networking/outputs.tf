output "egress_vpc_id" {
  value = module.networking.egress_vpc_id
}

output "egress_firewall_arn" {
  value = module.networking.egress_firewall_arn
}

output "egress_nat_public_ips" {
  value = module.networking.egress_nat_public_ips
}

output "egress_firewall_endpoint_ids" {
  value = module.networking.egress_firewall_endpoint_ids
}