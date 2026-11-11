
# Infrastructure private route table

resource "aws_route_table" "infrastructure_private" {
  provider = aws.infrastructure

  vpc_id = aws_vpc.infrastructure.id

  tags = merge(
    local.network_tags.infrastructure,
    {
      Name = "infrastructure-private-rt"
    }
  )
}

resource "aws_route_table_association" "infrastructure_private" {
  provider = aws.infrastructure

  for_each = aws_subnet.infrastructure_private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.infrastructure_private.id
}

# Production private route table

resource "aws_route_table" "production_private" {
  provider = aws.production

  vpc_id = aws_vpc.production.id

  tags = merge(
    local.network_tags.production,
    {
      Name = "production-private-rt"
    }
  )
}

resource "aws_route_table_association" "production_private" {
  provider = aws.production

  for_each = aws_subnet.production_private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.production_private.id
}

# NonProduction private route table

resource "aws_route_table" "nonproduction_private" {
  provider = aws.nonproduction

  vpc_id = aws_vpc.nonproduction.id

  tags = merge(
    local.network_tags.nonproduction,
    {
      Name = "nonproduction-private-rt"
    }
  )
}

resource "aws_route_table_association" "nonproduction_private" {
  provider = aws.nonproduction

  for_each = aws_subnet.nonproduction_private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.nonproduction_private.id
}



resource "aws_route_table" "infrastructure_isolated" {
  provider = aws.infrastructure

  vpc_id = aws_vpc.infrastructure.id

  tags = merge(
    local.network_tags.infrastructure,
    {
      Name = "infrastructure-isolated-rt"
    }
  )
}

resource "aws_route_table" "production_isolated" {
  provider = aws.production

  vpc_id = aws_vpc.production.id

  tags = merge(
    local.network_tags.production,
    {
      Name = "production-isolated-rt"
    }
  )
}

resource "aws_route_table" "nonproduction_isolated" {
  provider = aws.nonproduction

  vpc_id = aws_vpc.nonproduction.id

  tags = merge(
    local.network_tags.nonproduction,
    {
      Name = "nonproduction-isolated-rt"
    }
  )
}

resource "aws_route_table_association" "infrastructure_isolated" {
  provider = aws.infrastructure

  for_each = aws_subnet.infrastructure_isolated

  subnet_id      = each.value.id
  route_table_id = aws_route_table.infrastructure_isolated.id
}

resource "aws_route_table_association" "production_isolated" {
  provider = aws.production

  for_each = aws_subnet.production_isolated

  subnet_id      = each.value.id
  route_table_id = aws_route_table.production_isolated.id
}

resource "aws_route_table_association" "nonproduction_isolated" {
  provider = aws.nonproduction

  for_each = aws_subnet.nonproduction_isolated

  subnet_id      = each.value.id
  route_table_id = aws_route_table.nonproduction_isolated.id
}



# Production -> Infrastructure

resource "aws_route" "production_to_infrastructure" {
  provider = aws.production

  route_table_id         = aws_route_table.production_private.id
  destination_cidr_block = var.infrastructure_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# NonProduction -> Infrastructure

resource "aws_route" "nonproduction_to_infrastructure" {
  provider = aws.nonproduction

  route_table_id         = aws_route_table.nonproduction_private.id
  destination_cidr_block = var.infrastructure_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Infrastructure -> Production

resource "aws_route" "infrastructure_to_production" {
  provider = aws.infrastructure

  route_table_id         = aws_route_table.infrastructure_private.id
  destination_cidr_block = var.production_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# Infrastructure -> NonProduction

resource "aws_route" "infrastructure_to_nonproduction" {
  provider = aws.infrastructure

  route_table_id         = aws_route_table.infrastructure_private.id
  destination_cidr_block = var.nonproduction_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
