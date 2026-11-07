module "organizations" {
  source = "../../modules/organizations"

  expected_organization_id = var.expected_organization_id

  security_account_id = var.security_account_id
  logging_account_id  = var.logging_account_id

  security_ou_name = "Security"
  sandbox_ou_name  = "Sandbox"
}