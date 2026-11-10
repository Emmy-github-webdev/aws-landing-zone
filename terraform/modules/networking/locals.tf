
locals {
  common_tags = merge(
    var.policy_tags,
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
    private  = 0
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

# Egress

locals {
  egress_az_indices = {
    for index, az_id in var.availability_zone_ids :
    az_id => index
  }

  egress_subnet_cidrs = {
    for az_id, index in local.egress_az_indices :
    az_id => {
      firewall = cidrsubnet(
        var.egress_vpc_cidr,
        var.egress_firewall_subnet_newbits,
        index
      )

      tgw = cidrsubnet(
        var.egress_vpc_cidr,
        var.egress_tgw_subnet_newbits,
        index + 16
      )

      public = cidrsubnet(
        var.egress_vpc_cidr,
        var.egress_public_subnet_newbits,
        index + 32
      )
    }
  }
}


locals {
  firewall_endpoint_ids = var.enable_centralized_egress ? {
    for sync_state in aws_networkfirewall_firewall.egress[0].firewall_status[0].sync_states :
    sync_state.availability_zone_id => sync_state.attachment[0].endpoint_id
  } : {}
}


locals {
  az_name_to_id = zipmap(
    data.aws_availability_zones.available.names,
    data.aws_availability_zones.available.zone_ids
  )

  firewall_endpoint_ids = var.enable_centralized_egress ? {
    for sync_state in aws_networkfirewall_firewall.egress[0].firewall_status[0].sync_states :
    local.az_name_to_id[sync_state.availability_zone] => sync_state.attachment[0].endpoint_id
  } : {}
}
