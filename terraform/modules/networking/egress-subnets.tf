
resource "aws_subnet" "egress_firewall" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  vpc_id = aws_vpc.egress[0].id

  availability_zone_id = each.key
  cidr_block           = local.egress_subnet_cidrs[each.key].firewall

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "egress-firewall-${each.key}"
      Tier = "Firewall"
    }
  )
}

resource "aws_subnet" "egress_tgw" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  vpc_id = aws_vpc.egress[0].id

  availability_zone_id = each.key
  cidr_block           = local.egress_subnet_cidrs[each.key].tgw

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "egress-tgw-${each.key}"
      Tier = "TransitGateway"
    }
  )
}

resource "aws_subnet" "egress_public" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  vpc_id = aws_vpc.egress[0].id

  availability_zone_id = each.key
  cidr_block           = local.egress_subnet_cidrs[each.key].public

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "egress-public-${each.key}"
      Tier = "Public"
    }
  )
}
