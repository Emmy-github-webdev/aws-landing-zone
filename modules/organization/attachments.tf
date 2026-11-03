resource "aws_organizations_policy_attachment" "deny_leave" {
  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = local.root_id
}