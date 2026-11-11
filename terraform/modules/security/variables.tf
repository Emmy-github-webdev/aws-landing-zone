
variable "organization_id" {
  description = "Expected AWS Organization ID"
  type        = string
}

variable "management_account_id" {
  description = "AWS Organizations management account ID"
  type        = string
}

variable "security_account_id" {
  description = "Central security account ID"
  type        = string
}

variable "logging_account_id" {
  description = "Central logging account ID"
  type        = string
}

variable "approved_regions" {
  description = "AWS regions where security services are enabled"
  type        = list(string)

  validation {
    condition     = length(var.approved_regions) > 0
    error_message = "At least one approved region must be specified."
  }
}

variable "primary_region" {
  description = "Primary AWS region for centralized logging and aggregation"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cloudtrail_name" {
  description = "Organization CloudTrail name"
  type        = string
  default     = "organization-cloudtrail"
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 365
}

variable "config_aggregator_name" {
  description = "AWS Config aggregator name"
  type        = string
  default     = "organization-config-aggregator"
}

variable "enable_cloudtrail" {
  description = "Whether this regional deployment creates the organization CloudTrail"
  type        = bool
  default     = false
}

variable "enable_config_aggregator" {
  description = "Whether this deployment creates the central Config aggregator"
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = "Enable Security Hub"
  type        = bool
  default     = true
}

variable "enable_access_analyzer" {
  description = "Enable IAM Access Analyzer"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable Config aggregation"
  type        = bool
  default     = true
}

variable "policy_tags" {
  description = "Tags applied to security resources"
  type        = map(string)
}

variable "config_aggregator_role_arn" {
  description = "Role ARN used by AWS Config for organization aggregation"
  type        = string
}