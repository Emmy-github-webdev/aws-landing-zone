
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


resource "aws_route_table_association" "egress_public" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  subnet_id      = aws_subnet.egress_public[each.key].id
  route_table_id = aws_route_table.egress_public_az[each.key].id
}
