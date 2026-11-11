locals {
  organization_valid = (
    data.aws_organizations_organization.current.id ==
    var.expected_organization_id
  )
}