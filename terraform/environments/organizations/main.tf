import {
  to = module.organizations.aws_organizations_account.workloads
  id = "982498569597"
}

import {
  to = module.organizations.aws_organizations_account.production
  id = "161132473946"
}

import {
  to = module.organizations.aws_organizations_account.nonproduction
  id = "414473839373"
}

import {
  to = module.organizations.aws_organizations_account.infrastructure
  id = "503676493255"
}

# Organizations module
module "organizations" {
  source = "../../modules/organizations"

  expected_organization_id = var.expected_organization_id

  security_account_id                  = var.security_account_id
  logging_account_id                   = var.logging_account_id
  control_tower_baseline_version       = var.control_tower_baseline_version
  control_tower_baseline_arn           = var.control_tower_baseline_arn
  identity_center_enabled_baseline_arn = var.identity_center_enabled_baseline_arn

  security_ou_name             = var.security_ou_name
  sandbox_ou_name              = var.sandbox_ou_name
  infrastructure_ou_name       = var.infrastructure_ou_name
  workloads_ou_name            = var.workloads_ou_name
  production_ou_name           = var.production_ou_name
  nonproduction_ou_name        = var.nonproduction_ou_name
  infrastructure_account_email = var.infrastructure_account_email
  workloads_account_email      = var.workloads_account_email
  production_account_email     = var.production_account_email
  nonproduction_account_email  = var.nonproduction_account_email
  policy_tags                  = var.common_tags
}