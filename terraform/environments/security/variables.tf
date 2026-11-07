variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "security"
}

variable "expected_account_id" {
  type = string
}

variable "terraform_state_bucket" {
  type = string
}

variable "management_account_id" {
  type = string
}

variable "cloudtrail_bucket_name" {
  type = string
}