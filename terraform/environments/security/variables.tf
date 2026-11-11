variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

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
  type = string
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
