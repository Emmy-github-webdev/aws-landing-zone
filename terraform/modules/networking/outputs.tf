
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
