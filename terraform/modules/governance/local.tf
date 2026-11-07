locals {
  region_restriction_policy = jsondecode(
    templatefile(
      "${path.module}/policies/region-restriction.json",
      {
        approved_regions = var.approved_regions
      }
    )
  )
}