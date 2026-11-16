
data "terraform_remote_state" "organizations" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = "landing-zone/organizations/terraform.tfstate"
    region = var.state_region
  }
}

locals {
  infrastructure_account_id = (
    one([
      for account_id, account in data.terraform_remote_state.organizations.outputs.accounts :
      account_id if lower(account.name) == "infrastructure"
    ])
  )

  production_account_id = (
    one([
      for account_id, account in data.terraform_remote_state.organizations.outputs.accounts :
      account_id if lower(account.name) == "production"
    ])
  )

  nonproduction_account_id = (
    one([
      for account_id, account in data.terraform_remote_state.organizations.outputs.accounts :
      account_id if lower(account.name) == "nonproduction"
    ])
  )

}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "emmanuelogah-aws-lz-tfstate"
    key    = "landing-zone/networking/terraform.tfstate"
    region = var.state_region
  }
}

locals {
  shared_corporate_resolver_rule_id = (
    data.terraform_remote_state.networking.outputs.dns_corporate_resolver_rule_id
  )
}