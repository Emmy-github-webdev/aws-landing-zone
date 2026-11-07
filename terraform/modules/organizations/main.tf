# Infrastructure OU
resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = var.infrastructure_ou_name
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = {
    Name        = var.infrastructure_ou_name
    Environment = "Shared"
    Purpose     = "Infrastructure"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true

    precondition {
      condition = (
        data.aws_organizations_organization.current.id ==
        var.expected_organization_id
      )

      error_message = "Unexpected AWS Organization. Cannot create Infrastructure OU."
    }

    precondition {
      condition = !contains(
        [for ou in data.aws_organizations_organizational_units.root_ous.children : lower(ou.name)],
        lower(var.infrastructure_ou_name)
      )

      error_message = "Infrastructure OU already exists. Import it instead of creating another one."
    }
  }
}

# workloads OU
resource "aws_organizations_organizational_unit" "workloads" {
  name      = var.workloads_ou_name
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = {
    Name        = var.workloads_ou_name
    Environment = "Shared"
    Purpose     = "Application Workloads"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true

    precondition {
      condition = (
        data.aws_organizations_organization.current.id ==
        var.expected_organization_id
      )

      error_message = "Unexpected AWS Organization. Cannot create Workloads OU."
    }

    precondition {
      condition = !contains(
        [for ou in data.aws_organizations_organizational_units.root_ous.children : lower(ou.name)],
        lower(var.workloads_ou_name)
      )

      error_message = "Workloads OU already exists. Import it instead of creating another one."
    }
  }
}

# Child OUs under Workloads OU: Production and NonProduction
resource "aws_organizations_organizational_unit" "production" {
  name      = var.production_ou_name
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Name        = var.production_ou_name
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_organizational_unit" "nonproduction" {
  name      = var.nonproduction_ou_name
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Name        = var.nonproduction_ou_name
    Environment = "NonProduction"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Add Baseline resources to the Infrastructure
resource "aws_controltower_baseline" "infrastructure" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version

  target_identifier = aws_organizations_organizational_unit.infrastructure.arn

  parameters {
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Add Baseline resources to the Workloads
resource "aws_controltower_baseline" "workloads" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version

  target_identifier = aws_organizations_organizational_unit.workloads.arn

  parameters {
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Add Baseline resources to the Production
resource "aws_controltower_baseline" "production" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version

  target_identifier = aws_organizations_organizational_unit.production.arn

  parameters {
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }

  depends_on = [
    aws_controltower_baseline.workloads
  ]

  lifecycle {
    prevent_destroy = true
  }
}

# Add Baseline resources to the NonProduction
resource "aws_controltower_baseline" "nonproduction" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version

  target_identifier = aws_organizations_organizational_unit.nonproduction.arn

  parameters {
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }

  depends_on = [
    aws_controltower_baseline.workloads
  ]

  lifecycle {
    prevent_destroy = true
  }
}