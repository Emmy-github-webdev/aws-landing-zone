locals {
  region_restriction_policy = merge(
    jsondecode(file("${path.module}/policies/region_restriction_policy.json")),
    {
      Statement = [
        merge(
          jsondecode(file("${path.module}/policies/region_restriction_policy.json")).Statement[0],
          {
            Condition = {
              StringNotEquals = {
                "aws:RequestedRegion" = var.approved_regions
              }
            }
          }
        )
      ]
    }
  )

  organization_protection_policy = jsondecode(
    file("${path.module}/policies/organization_protection_policy.json")
  )
}
