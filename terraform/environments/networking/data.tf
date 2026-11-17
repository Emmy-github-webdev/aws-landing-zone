
data "terraform_remote_state" "organizations" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = "landing-zone/organizations/terraform.tfstate"
    region = var.state_region
  }
}

locals {
  infrastructure_account_id = data.terraform_remote_state.organizations.outputs.infrastructure_account_id
  production_account_id     = data.terraform_remote_state.organizations.outputs.production_account_id
  nonproduction_account_id  = data.terraform_remote_state.organizations.outputs.nonproduction_account_id
  organization_arn          = data.terraform_remote_state.organizations.outputs.organization_arn
  organization_id           = data.terraform_remote_state.organizations.outputs.organization_id
}