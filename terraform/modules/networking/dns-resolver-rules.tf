
resource "aws_security_group" "dns_resolver" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name        = "lz-central-dns-resolver-sg"
  description = "Security group for centralized Route 53 Resolver"
  vpc_id      = aws_vpc.infrastructure.id

  ingress {
    description = "DNS over UDP from approved networks"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"

    cidr_blocks = concat(
      var.dns_allowed_query_cidrs,
      var.dns_onpremises_cidrs
    )
  }

  ingress {
    description = "DNS over TCP from approved networks"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"

    cidr_blocks = concat(
      var.dns_allowed_query_cidrs,
      var.dns_onpremises_cidrs
    )
  }

  egress {
    description = "DNS to approved upstream servers"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"

    cidr_blocks = var.dns_onpremises_cidrs
  }

  egress {
    description = "DNS over TCP to approved upstream servers"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"

    cidr_blocks = var.dns_onpremises_cidrs
  }

  tags = merge(
    local.common_tags,
    {
      Name = "lz-central-dns-resolver-sg"
    }
  )
}


resource "aws_route53_resolver_endpoint" "inbound" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name      = "lz-central-dns-inbound"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.dns_resolver[0].id
  ]

  dynamic "ip_address" {
    for_each = var.dns_resolver_subnet_ids

    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "lz-central-dns-inbound"
    }
  )

  lifecycle {
    precondition {
      condition     = length(var.dns_resolver_subnet_ids) >= 2
      error_message = "At least two Resolver endpoint subnets in separate AZs are required."
    }
  }
}


resource "aws_route53_resolver_endpoint" "outbound" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name      = "lz-central-dns-outbound"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.dns_resolver[0].id
  ]

  dynamic "ip_address" {
    for_each = var.dns_resolver_subnet_ids

    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "lz-central-dns-outbound"
    }
  )

  lifecycle {
    precondition {
      condition     = length(var.dns_resolver_subnet_ids) >= 2
      error_message = "At least two Resolver endpoint subnets in separate AZs are required."
    }
  }
}


resource "aws_route53_resolver_rule" "corporate" {
  provider = aws.infrastructure

  count = (
    var.enable_dns_security &&
    length(var.dns_onpremises_resolver_ips) > 0
  ) ? 1 : 0

  domain_name          = var.dns_private_domain
  name                 = "lz-corporate-dns-forwarding"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound[0].id

  dynamic "target_ip" {
    for_each = var.dns_onpremises_resolver_ips

    content {
      ip = target_ip.value
      port = 53
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "lz-corporate-dns-forwarding"
    }
  )
}

resource "aws_route53_resolver_rule_association" "infrastructure" {
  provider = aws.infrastructure

  count = (
    var.enable_dns_security &&
    length(var.dns_onpremises_resolver_ips) > 0
  ) ? 1 : 0

  name             = "lz-infrastructure-corporate-dns"
  resolver_rule_id = aws_route53_resolver_rule.corporate[0].id
  vpc_id           = aws_vpc.infrastructure.id
}

data "aws_route53_resolver_rule" "corporate" {
  provider = aws.production

  resolver_rule_id = var.shared_corporate_resolver_rule_id
}

resource "aws_route53_resolver_rule_association" "corporate" {
  provider = aws.production

  name             = "lz-production-corporate-dns"
  resolver_rule_id = data.aws_route53_resolver_rule.corporate.id
  vpc_id           = aws_vpc.production.id
}

# Production DNS Resolver rule association

data "aws_route53_resolver_rule" "corporate_production" {
  provider = aws.production

  resolver_rule_id = var.shared_corporate_resolver_rule_id
}

resource "aws_route53_resolver_rule_association" "corporate_production" {
  provider = aws.production

  name             = "lz-production-corporate-dns"
  resolver_rule_id = data.aws_route53_resolver_rule.corporate_production.id
  vpc_id           = aws_vpc.production.id
}

# NonProduction DNS Resolver rule association

data "aws_route53_resolver_rule" "corporate_nonproduction" {
  provider = aws.nonproduction

  resolver_rule_id = var.shared_corporate_resolver_rule_id
}

resource "aws_route53_resolver_rule_association" "corporate_nonproduction" {
  provider = aws.nonproduction

  name             = "lz-nonproduction-corporate-dns"
  resolver_rule_id = data.aws_route53_resolver_rule.corporate_nonproduction.id
  vpc_id           = aws_vpc.nonproduction.id
}