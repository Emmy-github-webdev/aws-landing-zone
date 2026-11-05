resource "aws_organizations_organization" "banking" {
  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com"
  ]

  lifecycle {
    prevent_destroy = true
  }
}