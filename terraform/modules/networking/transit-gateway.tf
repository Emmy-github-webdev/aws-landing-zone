
resource "aws_ec2_transit_gateway" "main" {
  provider = aws.infrastructure

  description = "AWS Landing Zone Central Transit Gateway"

  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(
    local.common_tags,
    {
      Name = "lz-central-transit-gateway"
    }
  )
}

resource "aws_ram_resource_share" "transit_gateway" {
  provider = aws.infrastructure

  name                      = "lz-transit-gateway-share"
  allow_external_principals = false

  tags = local.common_tags
}

resource "aws_ram_resource_association" "transit_gateway" {
  provider = aws.infrastructure

  resource_arn = aws_ec2_transit_gateway.main.arn
  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
}

resource "aws_ram_principal_association" "organization" {
  provider = aws.infrastructure

  principal          = var.organization_id
  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
}

# Isolated Production routing domain
resource "aws_ec2_transit_gateway_route_table" "production" {
  provider = aws.infrastructure

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "lz-production-tgw-rt"
    }
  )
}

# Isolated NonProduction routing domain
resource "aws_ec2_transit_gateway_route_table" "nonproduction" {
  provider = aws.infrastructure

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "lz-nonproduction-tgw-rt"
    }
  )
}

# Shared infrastructure routing domain
resource "aws_ec2_transit_gateway_route_table" "infrastructure" {
  provider = aws.infrastructure

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "lz-infrastructure-tgw-rt"
    }
  )
}

# Transist gateway attachment


resource "aws_ec2_transit_gateway_vpc_attachment" "infrastructure" {
  provider = aws.infrastructure

  subnet_ids = aws_subnet.infrastructure_private[*].id

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id            = aws_vpc.infrastructure.id

  dns_support = "enable"

  tags = merge(
    local.common_tags,
    {
      Name = "lz-infrastructure-attachment"
    }
  )

  depends_on = [
    aws_ram_principal_association.organization
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "production" {
  provider = aws.production

  subnet_ids = aws_subnet.production_private[*].id

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id            = aws_vpc.production.id

  dns_support = "enable"

  tags = merge(
    local.common_tags,
    {
      Name = "lz-production-attachment"
    }
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "nonproduction" {
  provider = aws.nonproduction

  subnet_ids = aws_subnet.nonproduction_private[*].id

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id            = aws_vpc.nonproduction.id

  dns_support = "enable"

  tags = merge(
    local.common_tags,
    {
      Name = "lz-nonproduction-attachment"
    }
  )
}


# Route table association

resource "aws_ec2_transit_gateway_route_table_association" "infrastructure" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.infrastructure.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure.id
}

resource "aws_ec2_transit_gateway_route_table_association" "production" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.production.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production.id
}

resource "aws_ec2_transit_gateway_route_table_association" "nonproduction" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.nonproduction.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.nonproduction.id
}



# Infrastructure routes available to Production

resource "aws_ec2_transit_gateway_route_table_propagation" "infrastructure_to_production" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.infrastructure.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production.id
}

# Infrastructure routes available to NonProduction

resource "aws_ec2_transit_gateway_route_table_propagation" "infrastructure_to_nonproduction" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.infrastructure.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.nonproduction.id
}

# Production routes available to Infrastructure

resource "aws_ec2_transit_gateway_route_table_propagation" "production_to_infrastructure" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.production.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure.id
}

# NonProduction routes available to Infrastructure

resource "aws_ec2_transit_gateway_route_table_propagation" "nonproduction_to_infrastructure" {
  provider = aws.infrastructure

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.nonproduction.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.infrastructure.id
}
