# Remote terraform state for the Organizations module
data "terraform_remote_state" "organizations" {
  backend = "s3"

  config = {
    bucket = "emmanuelogah-aws-lz-tfstate"
    key    = "landing-zone/organizations/terraform.tfstate"
    region = var.aws_region
  }
}

# Reference the output from the Organizations module
locals {
  infrastructure_ou_id = data.terraform_remote_state.organizations.outputs.infrastructure_ou_id

  workloads_ou_id = data.terraform_remote_state.organizations.outputs.workloads_ou_id

  production_ou_id = data.terraform_remote_state.organizations.outputs.production_ou_id

  sandbox_ou_id = data.terraform_remote_state.organizations.outputs.sandbox_ou_id

  nonproduction_ou_id = data.terraform_remote_state.organizations.outputs.nonproduction_ou_id
}