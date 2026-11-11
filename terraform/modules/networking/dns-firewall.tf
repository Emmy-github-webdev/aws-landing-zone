# Infrastructure account
resource "aws_route53_resolver_firewall_domain_list" "blocked_infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name    = "lz-blocked-domains"
  domains = var.dns_firewall_blocked_domains

  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule_group" "infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name = "lz-dns-firewall-rules"

  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule" "blocked_infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name                    = "lz-block-malicious-domains"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.blocked_infrastructure[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.infrastructure[0].id
  priority                = 100

  firewall_domain_redirection_action = "INSPECT_REDIRECTION_DOMAIN"
}

resource "aws_route53_resolver_firewall_rule_group_association" "infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name                   = "lz-infrastructure-dns-firewall"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.infrastructure[0].id
  vpc_id                 = aws_vpc.infrastructure.id
  priority               = 100

  mutation_protection = "ENABLED"
}

# Production account

resource "aws_route53_resolver_firewall_domain_list" "blocked_production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name    = "lz-blocked-domains"
  domains = var.dns_firewall_blocked_domains

  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule_group" "production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name = "lz-dns-firewall-rules"

  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule" "blocked_production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name                    = "lz-block-malicious-domains"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.blocked_production[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.production[0].id
  priority                = 100

  firewall_domain_redirection_action = "INSPECT_REDIRECTION_DOMAIN"
}

resource "aws_route53_resolver_firewall_rule_group_association" "production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name                   = "lz-production-dns-firewall"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.production[0].id
  vpc_id                 = aws_vpc.production.id
  priority               = 100

  mutation_protection = "ENABLED"
}



# Nonproduction account

resource "aws_route53_resolver_firewall_domain_list" "blocked_nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name    = "lz-blocked-domains"
  domains = var.dns_firewall_blocked_domains

  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule_group" "nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name = "lz-dns-firewall-rules"

  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule" "blocked_nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name                    = "lz-block-malicious-domains"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.blocked_nonproduction[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.nonproduction[0].id
  priority                = 100

  firewall_domain_redirection_action = "INSPECT_REDIRECTION_DOMAIN"
}

resource "aws_route53_resolver_firewall_rule_group_association" "nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name                   = "lz-nonproduction-dns-firewall"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.nonproduction[0].id
  vpc_id                 = aws_vpc.nonproduction.id
  priority               = 100

  mutation_protection = "ENABLED"
}
