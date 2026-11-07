module "networking" {
  source = "../../modules/networking"

  providers = {
    aws.infrastructure = aws.infrastructure
    aws.production     = aws.production
    aws.nonproduction  = aws.nonproduction
  }

  organization_id = local.organization_id

  infrastructure_account_id = var.infrastructure_account_id
  production_account_id     = var.production_account_id
  nonproduction_account_id  = var.nonproduction_account_id

  primary_region = var.primary_region

  availability_zones = var.availability_zones

  infrastructure_vpc_cidr = var.infrastructure_vpc_cidr
  production_vpc_cidr     = var.production_vpc_cidr
  nonproduction_vpc_cidr  = var.nonproduction_vpc_cidr

  enable_nat_gateway = var.enable_nat_gateway

  enable_flow_logs = var.enable_flow_logs

  enable_s3_endpoint       = var.enable_s3_endpoint
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint
  enable_ssm_endpoints     = var.enable_ssm_endpoints

  common_tags = var.common_tags
}
