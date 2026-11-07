output "organization_arn" {
  description = "Existing AWS Organization ARN"
  value       = data.aws_organizations_organization.current.arn
}

output "management_account_id" {
  description = "AWS management account ID"
  value       = data.aws_organizations_organization.current.master_account_id
}

output "root_id" {
  description = "AWS Organization root ID"
  value       = data.aws_organizations_organization.current.roots[0].id
}

output "organizational_units" {
  description = "Existing root-level organizational units"

  value = {
    for ou in data.aws_organizations_organizational_units.root_ous.children :
    ou.name => {
      id  = ou.id
      arn = ou.arn
    }
  }
}

output "accounts" {
  description = "Existing AWS organization accounts"

  value = {
    for account in data.aws_organizations_organization.current.accounts :
    account.id => {
      name  = account.name
      state = account.state
    }
  }
}

output "organization_id" {
  description = "Existing AWS Organization ID"
  value       = data.aws_organizations_organization.current.id

  precondition {
    condition = (
      data.aws_organizations_organization.current.id ==
      var.expected_organization_id
    )

    error_message = "Wrong AWS Organization. Deployment stopped."
  }
}

output "security_account_id" {
  description = "Security account ID"
  value       = var.security_account_id

  precondition {
    condition = contains(
      [for account in data.aws_organizations_organization.current.accounts : account.id],
      var.security_account_id
    )

    error_message = "Security account does not belong to this organization."
  }
}

output "logging_account_id" {
  description = "Logging account ID"
  value       = var.logging_account_id

  precondition {
    condition = contains(
      [for account in data.aws_organizations_organization.current.accounts : account.id],
      var.logging_account_id
    )

    error_message = "Logging account does not belong to this organization."
  }
}

output "infrastructure_ou_id" {
  description = "Infrastructure OU ID"
  value       = aws_organizations_organizational_unit.infrastructure.id
}

output "workloads_ou_id" {
  description = "Workloads OU ID"
  value       = aws_organizations_organizational_unit.workloads.id
}

output "production_ou_id" {
  description = "Production OU ID"
  value       = aws_organizations_organizational_unit.production.id
}

output "nonproduction_ou_id" {
  description = "NonProduction OU ID"
  value       = aws_organizations_organizational_unit.nonproduction.id
}

output "infrastructure_baseline_arn" {
  value = aws_controltower_baseline.infrastructure.arn
}

output "workloads_baseline_arn" {
  value = aws_controltower_baseline.workloads.arn
}

output "production_baseline_arn" {
  value = aws_controltower_baseline.production.arn
}

output "nonproduction_baseline_arn" {
  value = aws_controltower_baseline.nonproduction.arn
}