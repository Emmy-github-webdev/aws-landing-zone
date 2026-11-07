module "security" {
  source = "../../modules/security"

  organization_id = data.terraform_remote_state.organizations.outputs.organization_id

  management_account_id = var.management_account_id
  security_account_id   = data.terraform_remote_state.organizations.outputs.security_account_id
  logging_account_id    = data.terraform_remote_state.organizations.outputs.logging_account_id

  cloudtrail_bucket_name = var.cloudtrail_bucket_name

  aws_regions = [
    "us-east-1",
    "us-west-2"
  ]

  enable_security_lake = true
  enable_inspector     = true
}