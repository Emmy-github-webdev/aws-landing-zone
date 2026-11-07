
locals {
  common_tags = merge(
    var.common_tags,
    {
      Organization = var.organization_id
      ManagedBy    = "Terraform"
    }
  )

  networks = {
    infrastructure = {
      cidr = var.infrastructure_vpc_cidr
      name = "infrastructure"
    }

    production = {
      cidr = var.production_vpc_cidr
      name = "production"
    }

    nonproduction = {
      cidr = var.nonproduction_vpc_cidr
      name = "nonproduction"
    }
  }

  network_tags = {
    for network, config in local.networks :
    network => merge(
      local.common_tags,
      {
        Network = config.name
      }
    )
  }
}


# Subnets

locals {
  az_indices = {
    for index, az in var.availability_zones :
    az => index
  }

  subnet_tiers = {
    private = 0
    isolated = 4
  }

  subnet_cidrs = {
    infrastructure = {
      for az, index in local.az_indices :
      az => {
        private = cidrsubnet(
          var.infrastructure_vpc_cidr, 4, index
        )

        isolated = cidrsubnet(
          var.infrastructure_vpc_cidr, 4, index + 4
        )
      }
    }

    production = {
      for az, index in local.az_indices :
      az => {
        private = cidrsubnet(
          var.production_vpc_cidr, 4, index
        )

        isolated = cidrsubnet(
          var.production_vpc_cidr, 4, index + 4
        )
      }
    }

    nonproduction = {
      for az, index in local.az_indices :
      az => {
        private = cidrsubnet(
          var.nonproduction_vpc_cidr, 4, index
        )

        isolated = cidrsubnet(
          var.nonproduction_vpc_cidr, 4, index + 4
        )
      }
    }
  }
}
