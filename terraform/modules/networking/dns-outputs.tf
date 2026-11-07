
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
