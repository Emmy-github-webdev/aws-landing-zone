
module "networking" {
  source = "../../modules/networking"

  providers = {
    aws                = aws.infrastructure
    aws.infrastructure = aws.infrastructure
    aws.production     = aws.production
    aws.nonproduction  = aws.nonproduction
  }

  organization_id = local.organization_id

  infrastructure_account_id = var.infrastructure_account_id
  production_account_id     = var.production_account_id
  nonproduction_account_id  = var.nonproduction_account_id

  primary_region = var.primary_region

  availability_zones    = var.availability_zones
  availability_zone_ids = var.availability_zone_ids

  infrastructure_vpc_cidr = var.infrastructure_vpc_cidr
  production_vpc_cidr     = var.production_vpc_cidr
  nonproduction_vpc_cidr  = var.nonproduction_vpc_cidr

  enable_centralized_egress = var.enable_centralized_egress
  egress_vpc_cidr           = var.egress_vpc_cidr

  firewall_home_net_cidrs = var.firewall_home_net_cidrs

  firewall_log_retention_days = var.firewall_log_retention_days
  firewall_allowed_tcp_ports = var.firewall_allowed_tcp_ports
  firewall_allowed_udp_ports = var.firewall_allowed_udp_ports

  enable_flow_logs = var.enable_flow_logs

  enable_s3_endpoint       = var.enable_s3_endpoint
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint

  
  enable_dns_security = var.enable_dns_security

  dns_resolver_subnet_ids = var.dns_resolver_subnet_ids

  dns_onpremises_resolver_ips = var.dns_onpremises_resolver_ips

  dns_private_domain = var.dns_private_domain

  dns_firewall_blocked_domains = var.dns_firewall_blocked_domains

  dns_allowed_query_cidrs = var.dns_allowed_query_cidrs

  dns_onpremises_cidrs = var.dns_onpremises_cidrs

  dns_log_retention_days = var.dns_log_retention_days

  organization_arn = var.organization_arn

  common_tags = var.common_tags
}
