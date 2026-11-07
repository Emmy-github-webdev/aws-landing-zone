
variable "terraform_state_bucket" {
  description = "S3 bucket containing Terraform remote state"
  type        = string
}

variable "state_region" {
  description = "Region hosting Terraform state"
  type        = string
}

variable "infrastructure_account_id" {
  type        = string
}

variable "production_account_id" {
  type        = string
}

variable "nonproduction_account_id" {
  type        = string
}

variable "infrastructure_role_arn" {
  type        = string
}

variable "production_role_arn" {
  type        = string
}

variable "nonproduction_role_arn" {
  type        = string
}

variable "primary_region" {
  type    = string
  default = "eu-west-1"
}

variable "availability_zones" {
  type = list(string)
}

variable "infrastructure_vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "production_vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "nonproduction_vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_flow_logs" {
  type    = bool
  default = true
}

variable "enable_s3_endpoint" {
  type    = bool
  default = true
}

variable "enable_dynamodb_endpoint" {
  type    = bool
  default = true
}

variable "enable_ssm_endpoints" {
  type    = bool
  default = true
}

variable "common_tags" {
  type = map(string)

  default = {
    ManagedBy = "Terraform"
    Project   = "AWS-Landing-Zone"
  }
}
