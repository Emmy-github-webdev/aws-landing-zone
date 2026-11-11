
output "dns_inbound_resolver_endpoint_id" {
  description = "Central inbound Resolver endpoint ID"

  value = try(
    aws_route53_resolver_endpoint.inbound[0].id,
    null
  )
}

output "dns_inbound_resolver_ips" {
  description = "Central inbound Resolver endpoint IP addresses"

  value = try([
    for ip in aws_route53_resolver_endpoint.inbound[0].ip_address :
    ip.ip
  ], [])
}

output "dns_outbound_resolver_endpoint_id" {
  description = "Central outbound Resolver endpoint ID"

  value = try(
    aws_route53_resolver_endpoint.outbound[0].id,
    null
  )
}

output "dns_corporate_resolver_rule_id" {
  description = "Corporate DNS forwarding rule ID"

  value = try(
    aws_route53_resolver_rule.corporate[0].id,
    null
  )
}

output "dns_infrastructure_firewall_association_id" {
  value = try(
    aws_route53_resolver_firewall_rule_group_association.infrastructure[0].id,
    null
  )
}

output "dns_production_firewall_association_id" {
  value = try(
    aws_route53_resolver_firewall_rule_group_association.production[0].id,
    null
  )
}

output "dns_nonproduction_firewall_association_id" {
  value = try(
    aws_route53_resolver_firewall_rule_group_association.nonproduction[0].id,
    null
  )
}

output "dns_infrastructure_log_group" {
  value = try(
    aws_cloudwatch_log_group.dns_infrastructure[0].name,
    null
  )
}

output "dns_production_log_group" {
  value = try(
    aws_cloudwatch_log_group.dns_production[0].name,
    null
  )
}

output "dns_nonproduction_log_group" {
  value = try(
    aws_cloudwatch_log_group.dns_nonproduction[0].name,
    null
  )
}

output "central_dns_log_destination_arn" {
  description = "Central CloudWatch Logs destination ARN"

  value = aws_cloudwatch_log_destination.central_dns.arn
}

output "central_dns_kinesis_stream_arn" {
  description = "Central DNS Kinesis stream ARN"

  value = aws_kinesis_stream.central_dns.arn
}

output "central_dns_kinesis_stream_name" {
  description = "Central DNS Kinesis stream name"

  value = aws_kinesis_stream.central_dns.name
}


output "central_dns_archive_bucket_name" {
  description = "Central DNS archive bucket"

  value = try(
    aws_s3_bucket.central_dns_archive[0].bucket,
    null
  )
}

output "central_dns_archive_bucket_arn" {
  description = "Central DNS archive bucket ARN"

  value = try(
    aws_s3_bucket.central_dns_archive[0].arn,
    null
  )
}

output "dns_firehose_infrastructure_arn" {
  value = try(
    module.dns_firehose_infrastructure[0].firehose_stream_arn,
    null
  )
}

output "dns_firehose_production_arn" {
  value = try(
    module.dns_firehose_production[0].firehose_stream_arn,
    null
  )
}

output "dns_firehose_nonproduction_arn" {
  value = try(
    module.dns_firehose_nonproduction[0].firehose_stream_arn,
    null
  )
}
