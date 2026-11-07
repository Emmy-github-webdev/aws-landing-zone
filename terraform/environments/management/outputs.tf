output "organization_id" {
  value = module.organizations.organization_id
}

output "management_account_id" {
  value = module.organizations.management_account_id
}

output "root_id" {
  value = module.organizations.root_id
}

output "organizational_units" {
  value = module.organizations.organizational_units
}

output "accounts" {
  value = module.organizations.accounts
}

output "infrastructure_ou_id" {
  value = module.organizations.infrastructure_ou_id
}

output "workloads_ou_id" {
  value = module.organizations.workloads_ou_id
}

output "production_ou_id" {
  value = module.organizations.production_ou_id
}

output "nonproduction_ou_id" {
  value = module.organizations.nonproduction_ou_id
}

output "infrastructure_baseline_arn" {
  value = module.organizations.infrastructure_baseline_arn
}

output "workloads_baseline_arn" {
  value = module.organizations.workloads_baseline_arn
}

output "production_baseline_arn" {
  value = module.organizations.production_baseline_arn
}

output "nonproduction_baseline_arn" {
  value = module.organizations.nonproduction_baseline_arn
}