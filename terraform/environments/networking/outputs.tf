
output "transit_gateway_id" {
  value = module.networking.transit_gateway_id
}

output "transit_gateway_arn" {
  value = module.networking.transit_gateway_arn
}

output "vpc_ids" {
  value = module.networking.vpc_ids
}

output "vpc_cidrs" {
  value = module.networking.vpc_cidrs
}

output "transit_gateway_attachments" {
  value = module.networking.transit_gateway_attachments
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "isolated_subnet_ids" {
  value = module.networking.isolated_subnet_ids
}
