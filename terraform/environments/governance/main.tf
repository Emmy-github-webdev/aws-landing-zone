# Governance module
module "governance" {
  source = "../../modules/governance"

  organization_id = var.expected_organization_id

  infrastructure_ou_id = local.infrastructure_ou_id
  workloads_ou_id      = local.workloads_ou_id
  production_ou_id     = local.production_ou_id
  nonproduction_ou_id  = local.nonproduction_ou_id

  sandbox_ou_id = var.sandbox_ou_id

  approved_regions = var.approved_regions
}