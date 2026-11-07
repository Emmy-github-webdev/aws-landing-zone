
variable "organization_id" {
  type        = string
  description = "AWS Organization ID"
}

variable "management_account_id" {
  type        = string
  description = "Management account ID"
}

variable "security_account_id" {
  type        = string
  description = "Security account ID"
}

variable "logging_account_id" {
  type        = string
  description = "Logging account ID"
}

variable "management_role_arn" {
  type        = string
  description = "Cross-account deployment role in management account"
}

variable "security_role_arn" {
  type        = string
  description = "Cross-account deployment role in security account"
}

variable "logging_role_arn" {
  type        = string
  description = "Cross-account deployment role in logging account"
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region"
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region"
}

variable "approved_regions" {
  type        = list(string)
  description = "Approved AWS regions"
}

variable "config_aggregator_role_arn" {
  type        = string
  description = "AWS Config organization aggregation role ARN"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "common_tags" {
  description = "Common infrastructure tags"
  type        = map(string)

  default = {
    ManagedBy   = "Terraform"
    Environment = "Security"
    Project     = "AWS-Landing-Zone"
  }
}
