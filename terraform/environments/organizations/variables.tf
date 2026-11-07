variable "aws_region" {
  description = "AWS Control Tower home region"
  type        = string
}

variable "expected_organization_id" {
  type = string
}

variable "security_account_id" {
  type = string
}

variable "logging_account_id" {
  type = string
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
  description = "AWS Control Tower baseline ARN for Identity Center enabled accounts"
  type        = string
}