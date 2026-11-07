variable "aws_region" {
  description = "AWS Control Tower home region"
  type        = string
}

variable "expected_organization_id" {
  type    = string
}

variable "security_account_id" {
  type    = string
}

variable "logging_account_id" {
  type    = string
}