
resource "aws_ec2_transit_gateway_route_table" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "lz-egress-inspection-tgw-rt"
    }
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  subnet_ids = [
    for subnet in values(aws_subnet.egress_tgw) :
    subnet.id
  ]

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.egress[0].id

  options {
    appliance_mode_support = "enable"
    dns_support            = "enable"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "lz-egress-inspection-attachment"
    }
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.egress[0].id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress[0].id
}

#Propagate workload routes into the inspection route table

resource "aws_ec2_transit_gateway_route_table_propagation" "egress_production" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.production.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "egress_nonproduction" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.nonproduction.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress[0].id
}

# Redirect spoke default routes to inspection

resource "aws_ec2_transit_gateway_route" "production_default_egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.egress[0].id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production.id
}

resource "aws_ec2_transit_gateway_route" "nonproduction_default_egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.egress[0].id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.nonproduction.id
}

# the egress route to the workload VPCs

resource "aws_route" "production_default_egress" {
  provider = aws.production

  count = var.enable_centralized_egress ? 1 : 0

  route_table_id         = aws_route_table.production_private.id
  destination_cidr_block = "0.0.0.0/0"

  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "nonproduction_default_egress" {
  provider = aws.nonproduction

  count = var.enable_centralized_egress ? 1 : 0

  route_table_id         = aws_route_table.nonproduction_private.id
  destination_cidr_block = "0.0.0.0/0"

  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

# Create per-AZ route tables

# TGW attachment subnet route tables

resource "aws_route_table" "egress_tgw" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  vpc_id = aws_vpc.egress[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "egress-tgw-rt-${each.key}"
    }
  )
}

resource "aws_route_table_association" "egress_tgw" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  subnet_id      = aws_subnet.egress_tgw[each.key].id
  route_table_id = aws_route_table.egress_tgw[each.key].id
}

# Firewall endpoint subnet route tables

resource "aws_route_table" "egress_firewall" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  vpc_id = aws_vpc.egress[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "egress-firewall-rt-${each.key}"
    }
  )
}

resource "aws_route_table_association" "egress_firewall" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  subnet_id      = aws_subnet.egress_firewall[each.key].id
  route_table_id = aws_route_table.egress_firewall[each.key].id
}

# NAT Gateway public subnet route tables

resource "aws_route_table" "egress_public_az" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  vpc_id = aws_vpc.egress[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "egress-public-rt-${each.key}"
    }
  )
}

resource "aws_route_table_association" "egress_public_az" {
  provider = aws.infrastructure

  for_each = var.enable_centralized_egress ? local.egress_az_indices : {}

  subnet_id      = aws_subnet.egress_public[each.key].id
  route_table_id = aws_route_table.egress_public_az[each.key].id
}


resource "aws_route" "egress_tgw_to_firewall" {
  provider = aws.infrastructure

  for_each = local.firewall_endpoint_ids

  route_table_id         = aws_route_table.egress_tgw[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  vpc_endpoint_id = each.value

  depends_on = [
    aws_networkfirewall_firewall.egress
  ]
}

# Firewall subnet routes

resource "aws_route" "firewall_to_nat" {
  provider = aws.infrastructure

  for_each = local.egress_az_indices

  route_table_id         = aws_route_table.egress_firewall[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.egress[each.key].id
}

resource "aws_route" "firewall_to_production" {
  provider = aws.infrastructure

  for_each = local.egress_az_indices

  route_table_id         = aws_route_table.egress_firewall[each.key].id
  destination_cidr_block = var.production_vpc_cidr

  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "firewall_to_nonproduction" {
  provider = aws.infrastructure

  for_each = local.egress_az_indices

  route_table_id         = aws_route_table.egress_firewall[each.key].id
  destination_cidr_block = var.nonproduction_vpc_cidr

  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

# Public NAT subnet routes

resource "aws_route" "public_to_internet" {
  provider = aws.infrastructure

  for_each = local.egress_az_indices

  route_table_id         = aws_route_table.egress_public_az[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.egress[0].id
}

resource "aws_route" "public_to_firewall_production" {
  provider = aws.infrastructure

  for_each = local.egress_az_indices

  route_table_id         = aws_route_table.egress_public_az[each.key].id
  destination_cidr_block = var.production_vpc_cidr

  vpc_endpoint_id = local.firewall_endpoint_ids[each.key]
}

resource "aws_route" "public_to_firewall_nonproduction" {
  provider = aws.infrastructure

  for_each = local.egress_az_indices

  route_table_id         = aws_route_table.egress_public_az[each.key].id
  destination_cidr_block = var.nonproduction_vpc_cidr

  vpc_endpoint_id = local.firewall_endpoint_ids[each.key]
}
