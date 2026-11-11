
resource "aws_vpc_endpoint" "infrastructure_s3" {
  provider = aws.infrastructure
  count    = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.infrastructure.id
  service_name      = "com.amazonaws.${var.primary_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.infrastructure_private.id
  ]

  tags = merge(
    local.network_tags.infrastructure,
    {
      Name = "infrastructure-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "production_s3" {
  provider = aws.production
  count    = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.production.id
  service_name      = "com.amazonaws.${var.primary_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.production_private.id
  ]

  tags = merge(
    local.network_tags.production,
    {
      Name = "production-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "nonproduction_s3" {
  provider = aws.nonproduction
  count    = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.nonproduction.id
  service_name      = "com.amazonaws.${var.primary_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.nonproduction_private.id
  ]

  tags = merge(
    local.network_tags.nonproduction,
    {
      Name = "nonproduction-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "infrastructure_dynamodb" {
  provider = aws.infrastructure
  count    = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = aws_vpc.infrastructure.id
  service_name      = "com.amazonaws.${var.primary_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.infrastructure_private.id
  ]

  tags = local.network_tags.infrastructure
}

resource "aws_vpc_endpoint" "production_dynamodb" {
  provider = aws.production
  count    = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = aws_vpc.production.id
  service_name      = "com.amazonaws.${var.primary_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.production_private.id
  ]

  tags = local.network_tags.production
}

resource "aws_vpc_endpoint" "nonproduction_dynamodb" {
  provider = aws.nonproduction
  count    = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = aws_vpc.nonproduction.id
  service_name      = "com.amazonaws.${var.primary_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.nonproduction_private.id
  ]

  tags = local.network_tags.nonproduction
}
