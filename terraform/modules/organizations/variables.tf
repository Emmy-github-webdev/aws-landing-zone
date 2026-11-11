variable "expected_organization_id" {
  description = "Expected existing AWS Organization ID"
  type        = string
}

variable "security_ou_name" {
  description = "Existing Security OU name"
  type        = string
}

variable "sandbox_ou_name" {
  description = "Existing Sandbox OU name"
  type        = string
}

variable "security_account_id" {
  description = "Account configured for Control Tower security roles and Config"
  type        = string
}

variable "logging_account_id" {
  description = "Account configured for Control Tower centralized logging"
  type        = string
}

variable "infrastructure_ou_name" {
  description = "Name of the Infrastructure OU"
  type        = string
}

variable "workloads_ou_name" {
  description = "Name of the Workloads OU"
  type        = string
}

variable "production_ou_name" {
  description = "Name of the Production child OU"
  type        = string
}

variable "nonproduction_ou_name" {
  description = "Name of the NonProduction child OU"
  type        = string
}

variable "control_tower_baseline_arn" {
  description = "AWS Control Tower baseline ARN"
  type        = string
}

variable "control_tower_baseline_version" {
  description = "AWS Control Tower baseline version"
  type        = string
}

variable "identity_center_enabled_baseline_arn" {
  description = "Existing Identity Center enabled baseline ARN"
  type        = string
}