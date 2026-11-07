
resource "aws_eip" "egress_nat" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "egress-nat-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "egress" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  allocation_id = aws_eip.egress_nat[each.key].id
  subnet_id     = aws_subnet.egress_public[each.key].id

  connectivity_type = "public"

  tags = merge(
    local.common_tags,
    {
      Name = "lz-egress-nat-${each.key}"
    }
  )

  depends_on = [
    aws_internet_gateway.egress
  ]
}


# Public route tables

resource "aws_route_table" "egress_public" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  vpc_id = aws_vpc.egress[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "lz-egress-public-rt"
    }
  )
}

resource "aws_route" "egress_public_internet" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  route_table_id         = aws_route_table.egress_public[0].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.egress[0].id
}

resource "aws_route_table_association" "egress_public" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  subnet_id      = aws_subnet.egress_public[each.key].id
  route_table_id = aws_route_table.egress_public[0].id
}
