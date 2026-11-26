resource "aws_customer_gateway" "onpremises" {
  provider = aws.infrastructure

  count = var.enable_onpremises_vpn ? 1 : 0

  bgp_asn    = var.onpremises_bgp_asn
  ip_address = var.onpremises_customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    local.common_tags,
    {
      Name = "lz-onpremises-customer-gateway"
    }
  )
}

resource "aws_vpn_connection" "onpremises" {
  provider = aws.infrastructure

  count = var.enable_onpremises_vpn ? 1 : 0

  customer_gateway_id = aws_customer_gateway.onpremises[0].id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = merge(
    local.common_tags,
    {
      Name = "lz-onpremises-site-to-site-vpn"
    }
  )
}

resource "aws_ec2_transit_gateway_route" "onpremises_vpc_routes" {
  provider = aws.infrastructure

  for_each = var.enable_onpremises_vpn ? local.onpremises_vpc_cidrs : {}

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onpremises[0].id
}

resource "aws_ec2_transit_gateway_route" "vpc_to_onpremises_via_inspection" {
  provider = aws.infrastructure

  for_each = var.enable_onpremises_vpn ? {
    for pair in setproduct(
      keys(local.onpremises_vpc_tgw_route_tables),
      var.onpremises_cidrs
      ) : "${pair[0]}-${pair[1]}" => {
      route_table_id = local.onpremises_vpc_tgw_route_tables[pair[0]]
      cidr           = pair[1]
    }
  } : {}

  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress[0].id
  transit_gateway_route_table_id = each.value.route_table_id
}
