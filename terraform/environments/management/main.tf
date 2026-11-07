module "organizations" {
  source = "../../modules/organizations"

  expected_organization_id = var.expected_organization_id

  security_account_id                  = var.security_account_id
  logging_account_id                   = var.logging_account_id
  control_tower_baseline_version       = var.control_tower_baseline_version
  control_tower_baseline_arn           = var.control_tower_baseline_arn
  identity_center_enabled_baseline_arn = var.identity_center_enabled_baseline_arn

  security_ou_name = "Security"
  sandbox_ou_name  = "Sandbox"
}