
resource "aws_security_group" "infrastructure_internal" {
  provider = aws.infrastructure

  name        = "infrastructure-internal"
  description = "Infrastructure internal communication"
  vpc_id      = aws_vpc.infrastructure.id

  tags = local.network_tags.infrastructure
}

resource "aws_security_group" "production_internal" {
  provider = aws.production

  name        = "production-internal"
  description = "Production internal communication"
  vpc_id      = aws_vpc.production.id

  tags = local.network_tags.production
}

resource "aws_security_group" "nonproduction_internal" {
  provider = aws.nonproduction

  name        = "nonproduction-internal"
  description = "NonProduction internal communication"
  vpc_id      = aws_vpc.nonproduction.id

  tags = local.network_tags.nonproduction
}

resource "aws_vpc_security_group_egress_rule" "infrastructure_internal" {
  provider = aws.infrastructure

  security_group_id = aws_security_group.infrastructure_internal.id

  ip_protocol = "-1"
  cidr_ipv4   = var.infrastructure_vpc_cidr
  description = "Infrastructure VPC internal traffic"
}

resource "aws_vpc_security_group_egress_rule" "production_internal" {
  provider = aws.production

  security_group_id = aws_security_group.production_internal.id

  ip_protocol = "-1"
  cidr_ipv4   = var.production_vpc_cidr
  description = "Production VPC internal traffic"
}

resource "aws_vpc_security_group_egress_rule" "nonproduction_internal" {
  provider = aws.nonproduction

  security_group_id = aws_security_group.nonproduction_internal.id

  ip_protocol = "-1"
  cidr_ipv4   = var.nonproduction_vpc_cidr
  description = "NonProduction VPC internal traffic"
}

resource "aws_vpc_security_group_ingress_rule" "infrastructure_onpremises_icmp" {
  provider = aws.infrastructure

  for_each = var.enable_onpremises_vpn ? {
    for cidr in var.onpremises_cidrs : cidr => cidr
  } : {}

  security_group_id = aws_security_group.infrastructure_internal.id
  cidr_ipv4         = each.value
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
  description       = "On-premises ICMP echo requests"
}

resource "aws_vpc_security_group_ingress_rule" "production_onpremises_icmp" {
  provider = aws.production

  for_each = var.enable_onpremises_vpn ? {
    for cidr in var.onpremises_cidrs : cidr => cidr
  } : {}

  security_group_id = aws_security_group.production_internal.id
  cidr_ipv4         = each.value
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
  description       = "On-premises ICMP echo requests"
}

resource "aws_vpc_security_group_ingress_rule" "nonproduction_onpremises_icmp" {
  provider = aws.nonproduction

  for_each = var.enable_onpremises_vpn ? {
    for cidr in var.onpremises_cidrs : cidr => cidr
  } : {}

  security_group_id = aws_security_group.nonproduction_internal.id
  cidr_ipv4         = each.value
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
  description       = "On-premises ICMP echo requests"
}
