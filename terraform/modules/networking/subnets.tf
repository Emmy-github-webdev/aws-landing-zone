# Infrastructure Private Subnets
resource "aws_subnet" "infrastructure_private" {
  provider = aws.infrastructure

  for_each = local.az_indices

  vpc_id = aws_vpc.infrastructure.id

  availability_zone = each.key
  cidr_block        = local.subnet_cidrs.infrastructure[each.key].private

  map_public_ip_on_launch = false

  tags = merge(
    local.network_tags.infrastructure,
    {
      Name = "infrastructure-private-${each.key}"
      Tier = "Private"
    }
  )
}


resource "aws_subnet" "infrastructure_isolated" {
  provider = aws.infrastructure

  for_each = local.az_indices

  vpc_id = aws_vpc.infrastructure.id

  availability_zone = each.key
  cidr_block        = local.subnet_cidrs.infrastructure[each.key].isolated

  map_public_ip_on_launch = false

  tags = merge(
    local.network_tags.infrastructure,
    {
      Name = "infrastructure-isolated-${each.key}"
      Tier = "Isolated"
    }
  )
}

# Production Private Subnets
resource "aws_subnet" "production_private" {
  provider = aws.production

  for_each = local.az_indices

  vpc_id = aws_vpc.production.id

  availability_zone = each.key
  cidr_block        = local.subnet_cidrs.production[each.key].private

  map_public_ip_on_launch = false

  tags = merge(
    local.network_tags.production,
    {
      Name = "production-private-${each.key}"
      Tier = "Private"
    }
  )
}

# Production Isolated Subnets
resource "aws_subnet" "production_isolated" {
  provider = aws.production

  for_each = local.az_indices

  vpc_id = aws_vpc.production.id

  availability_zone = each.key
  cidr_block        = local.subnet_cidrs.production[each.key].isolated

  map_public_ip_on_launch = false

  tags = merge(
    local.network_tags.production,
    {
      Name = "production-isolated-${each.key}"
      Tier = "Isolated"
    }
  )
}


# nonproduction private subnet

resource "aws_subnet" "nonproduction_private" {
  provider = aws.nonproduction

  for_each = local.az_indices

  vpc_id = aws_vpc.nonproduction.id

  availability_zone = each.key
  cidr_block        = local.subnet_cidrs.nonproduction[each.key].private

  map_public_ip_on_launch = false

  tags = merge(
    local.network_tags.nonproduction,
    {
      Name = "nonproduction-private-${each.key}"
      Tier = "Private"
    }
  )
}

resource "aws_subnet" "nonproduction_isolated" {
  provider = aws.nonproduction

  for_each = local.az_indices

  vpc_id = aws_vpc.nonproduction.id

  availability_zone = each.key
  cidr_block        = local.subnet_cidrs.nonproduction[each.key].isolated

  map_public_ip_on_launch = false

  tags = merge(
    local.network_tags.nonproduction,
    {
      Name = "nonproduction-isolated-${each.key}"
      Tier = "Isolated"
    }
  )
}
