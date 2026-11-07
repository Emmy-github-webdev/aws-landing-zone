resource "aws_organizations_policy" "region_restriction" {
  name        = "DenyUnapprovedRegions"
  description = "Restrict deployments to approved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode(local.region_restriction_policy)

  tags = var.policy_tags
}

resource "aws_organizations_policy" "organization_protection" {
  name        = "DenyLeavingOrganization"
  description = "Prevent member accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode(local.organization_protection_policy)

  tags = var.policy_tags
}

# Attach the region policy to the workloads organization
resource "aws_organizations_policy_attachment" "region_workloads" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = var.workloads_ou_id
}

#  Add organization validation to protects against accidentally deploying governance policies to the wrong organization
data "aws_organizations_organization" "current" {}

output "organization_id" {
  value = data.aws_organizations_organization.current.id

  precondition {
    condition = (
      data.aws_organizations_organization.current.id ==
      var.organization_id
    )

    error_message = "Unexpected AWS Organization. Governance deployment stopped."
  }
}