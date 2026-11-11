locals {
  region_restriction_policy = templatefile(
    "${path.module}/policies/region_restriction_policy.json",
    {
      approved_regions = jsonencode(var.approved_regions)
    }
  )

  organization_protection_policy = file(
    "${path.module}/policies/organization_protection_policy.json"
  )
}

locals {
  organization_valid = (
    data.aws_organizations_organization.current.id ==
    var.organization_id
  )
}