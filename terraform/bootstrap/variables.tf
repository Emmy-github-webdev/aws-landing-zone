variable "aws_region" {
  description = "AWS Control Tower home region"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique Terraform state bucket name"
  type        = string
}

variable "state_bucket_force_destroy" {
  description = "Allow bucket deletion when it contains objects"
  type        = bool
  default     = false
}