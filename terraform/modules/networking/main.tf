resource "terraform_data" "account_validation" {
  input = {
    infrastructure = data.aws_caller_identity.infrastructure.account_id
    production     = data.aws_caller_identity.production.account_id
    nonproduction  = data.aws_caller_identity.nonproduction.account_id
  }

  lifecycle {
    precondition {
      condition = (
        data.aws_caller_identity.infrastructure.account_id ==
        var.infrastructure_account_id
      )

      error_message = "Incorrect Infrastructure account."
    }

    precondition {
      condition = (
        data.aws_caller_identity.production.account_id ==
        var.production_account_id
      )

      error_message = "Incorrect Production account."
    }

    precondition {
      condition = (
        data.aws_caller_identity.nonproduction.account_id ==
        var.nonproduction_account_id
      )

      error_message = "Incorrect NonProduction account."
    }

    precondition {
      condition = alltrue([
        for az in var.availability_zones :
        contains(data.aws_availability_zones.available.names, az)
      ])

      error_message = "One or more configured Availability Zones are unavailable in the Infrastructure account."
    }
  }
}
