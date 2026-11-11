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

output "dns_inbound_resolver_ips" {
  value = module.networking.dns_inbound_resolver_ips
}

output "dns_outbound_resolver_endpoint_id" {
  value = module.networking.dns_outbound_resolver_endpoint_id
}

output "dns_corporate_resolver_rule_id" {
  value = module.networking.dns_corporate_resolver_rule_id
}

output "central_dns_log_destination_arn" {
  value = module.networking.central_dns_log_destination_arn
}

output "central_dns_kinesis_stream_arn" {
  value = module.networking.central_dns_kinesis_stream_arn
}

output "central_dns_archive_bucket_name" {
  value = module.networking.central_dns_archive_bucket_name
}

output "central_dns_archive_bucket_arn" {
  value = module.networking.central_dns_archive_bucket_arn
}

output "dns_firehose_infrastructure_arn" {
  value = module.networking.dns_firehose_infrastructure_arn
}

output "dns_firehose_production_arn" {
  value = module.networking.dns_firehose_production_arn
}

output "dns_firehose_nonproduction_arn" {
  value = module.networking.dns_firehose_nonproduction_arn
}