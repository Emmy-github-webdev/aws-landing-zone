
output "transit_gateway_id" {
  description = "Central Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_arn" {
  description = "Central Transit Gateway ARN"
  value       = aws_ec2_transit_gateway.main.arn
}

output "transit_gateway_route_tables" {
  description = "Transit Gateway routing domains"

  value = {
    infrastructure = aws_ec2_transit_gateway_route_table.infrastructure.id
    production     = aws_ec2_transit_gateway_route_table.production.id
    nonproduction  = aws_ec2_transit_gateway_route_table.nonproduction.id
  }
}

output "transit_gateway_attachments" {
  description = "Transit Gateway VPC attachment IDs"

  value = {
    infrastructure = aws_ec2_transit_gateway_vpc_attachment.infrastructure.id
    production     = aws_ec2_transit_gateway_vpc_attachment.production.id
    nonproduction  = aws_ec2_transit_gateway_vpc_attachment.nonproduction.id
  }
}

output "onpremises_customer_gateway_id" {
  description = "On-premises Customer Gateway ID, if the VPN is enabled"
  value       = try(aws_customer_gateway.onpremises[0].id, null)
}

output "onpremises_vpn_connection_id" {
  description = "Site-to-Site VPN connection ID, if enabled"
  value       = try(aws_vpn_connection.onpremises[0].id, null)
}

output "onpremises_transit_gateway_route_table_id" {
  description = "Transit Gateway route table associated with the VPN attachment"
  value       = try(aws_ec2_transit_gateway_route_table.onpremises[0].id, null)
}

output "vpc_ids" {
  description = "Landing Zone VPC IDs"

  value = {
    infrastructure = aws_vpc.infrastructure.id
    production     = aws_vpc.production.id
    nonproduction  = aws_vpc.nonproduction.id
  }
}

output "vpc_cidrs" {
  description = "VPC CIDR allocations"

  value = {
    infrastructure = aws_vpc.infrastructure.cidr_block
    production     = aws_vpc.production.cidr_block
    nonproduction  = aws_vpc.nonproduction.cidr_block
  }
}

output "private_subnet_ids" {
  description = "Private subnet IDs"

  value = {
    infrastructure = [
      for subnet in aws_subnet.infrastructure_private : subnet.id
    ]

    production = [
      for subnet in aws_subnet.production_private : subnet.id
    ]

    nonproduction = [
      for subnet in aws_subnet.nonproduction_private : subnet.id
    ]
  }
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs"

  value = {
    infrastructure = [
      for subnet in aws_subnet.infrastructure_isolated : subnet.id
    ]

    production = [
      for subnet in aws_subnet.production_isolated : subnet.id
    ]

    nonproduction = [
      for subnet in aws_subnet.nonproduction_isolated : subnet.id
    ]
  }
}
