variable "aws_region" {
  description = "AWS Control Tower home region"
  type        = string
  default     = "eu-west-1"
}

variable "control_tower_version" {
  description = "Supported Control Tower landing zone version"
  type        = string
  default     = "4.0"
}

variable "audit_account_email" {
  type = string
}

variable "log_archive_account_email" {
  type = string
}