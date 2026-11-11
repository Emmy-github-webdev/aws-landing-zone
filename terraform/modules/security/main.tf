resource "terraform_data" "account_validation" {
  input = {
    security_account_id   = data.aws_caller_identity.security.account_id
    management_account_id = data.aws_caller_identity.management.account_id
    logging_account_id    = data.aws_caller_identity.logging.account_id
  }

  lifecycle {
    precondition {
      condition = (
        data.aws_caller_identity.security.account_id ==
        var.security_account_id
      )

      error_message = "AWS provider is not authenticated to the expected Security account."
    }

    precondition {
      condition = (
        data.aws_caller_identity.management.account_id ==
        var.management_account_id
      )

      error_message = "AWS provider is not authenticated to the expected Management account."
    }

    precondition {
      condition = (
        data.aws_caller_identity.logging.account_id ==
        var.logging_account_id
      )

      error_message = "AWS provider is not authenticated to the expected Logging account."
    }

    precondition {
      condition = (
        data.aws_organizations_organization.current.id ==
        var.organization_id
      )

      error_message = "Unexpected AWS Organization. Security deployment stopped."
    }

    precondition {
      condition = (
        data.aws_organizations_organization.current.master_account_id ==
        var.management_account_id
      )

      error_message = "The configured management account does not own this organization."
    }
  }
}