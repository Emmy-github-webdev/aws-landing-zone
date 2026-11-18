# Governance module
module "governance" {
  source = "../../modules/governance"

  organization_id      = var.expected_organization_id
  organization_root_id = var.organization_root_id
  infrastructure_ou_id = local.infrastructure_ou_id
  workloads_ou_id      = local.workloads_ou_id
  production_ou_id     = local.production_ou_id
  nonproduction_ou_id  = local.nonproduction_ou_id
  network_account_ids = {
    infrastructure = local.infrastructure_account_id
    workloads      = local.workloads_account_id
    production     = local.production_account_id
    nonproduction  = local.nonproduction_account_id
  }

  sandbox_ou_id = var.sandbox_ou_id

  approved_regions = var.approved_regions

  policy_tags = var.common_tags
}