variable "infrastructure_ou_id" {
  description = "Infrastructure OU ID"
  type        = string
}

variable "workloads_ou_id" {
  description = "Workloads OU ID"
  type        = string
}

variable "production_ou_id" {
  description = "Production OU ID"
  type        = string
}

variable "nonproduction_ou_id" {
  description = "NonProduction OU ID"
  type        = string
}

variable "sandbox_ou_id" {
  description = "Existing Sandbox OU ID"
  type        = string
}

variable "approved_regions" {
  description = "Approved AWS deployment regions"
  type        = list(string)
  
  validation {
    condition     = length(var.approved_regions) > 0
    error_message = "At least one approved AWS region must be specified."
  }

}

variable "organization_id" {
  description = "Expected AWS Organization ID"
  type        = string
}

variable "organization_root_id" {
  description = "AWS Organization root ID"
  type        = string
}

variable "policy_tags" {
  description = "Tags applied to custom SCPs"
  type        = map(string)

  default = {
    ManagedBy = "Terraform"
    Project   = "AWS-Landing-Zone"
  }
}