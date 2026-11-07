# Infrastructure Baseline
resource "aws_controltower_baseline" "infrastructure" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.infrastructure.arn

  parameters {
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Workloads Baseline
resource "aws_controltower_baseline" "workloads" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.workloads.arn

  parameters {
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Production Baseline
resource "aws_controltower_baseline" "production" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.production.arn

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

# NonProduction Baseline
resource "aws_controltower_baseline" "nonproduction" {
  baseline_identifier = var.control_tower_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.nonproduction.arn

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