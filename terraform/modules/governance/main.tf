resource "aws_organizations_policy" "region_restriction" {
  name        = "DenyUnapprovedRegions"
  description = "Restrict deployments to approved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = local.region_restriction_policy

  lifecycle {
    precondition {
      condition = local.organization_valid

      error_message = "Unexpected AWS Organization. Governance deployment stopped."
    }
  }

  tags = var.policy_tags
}

resource "aws_organizations_policy" "organization_protection" {
  name        = "DenyLeavingOrganization"
  description = "Prevent member accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = local.organization_protection_policy

  lifecycle {
    precondition {
      condition = local.organization_valid

      error_message = "Unexpected AWS Organization. Governance deployment stopped."
    }
  }

  tags = var.policy_tags
}

# Attach region restriction to Workloads OU.
# Production and NonProduction inherit this policy.
resource "aws_organizations_policy_attachment" "region_workloads" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = var.workloads_ou_id
}

# Protect member accounts from leaving the organization.
# Attach at root to cover all member accounts.

resource "aws_organizations_policy_attachment" "organization_protection_root" {
  policy_id = aws_organizations_policy.organization_protection.id
  target_id = var.organization_root_id
}

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