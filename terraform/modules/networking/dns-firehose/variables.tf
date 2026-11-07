
variable "source_name" {
  description = "Source environment name"
  type        = string
}

variable "source_account_id" {
  description = "Expected AWS source account ID"
  type        = string
}

variable "source_log_group_name" {
  description = "CloudWatch DNS query log group"
  type        = string
}

variable "destination_bucket_arn" {
  description = "Central Logging account S3 bucket ARN"
  type        = string
}

variable "destination_prefix" {
  description = "S3 destination prefix for this account"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
