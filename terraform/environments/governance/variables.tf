variable "expected_organization_id" {
  type = string
}

variable "organization_root_id" {
  description = "Root ID of the AWS Organization"
  type        = string

}

variable "sandbox_ou_id" {
  description = "Existing Sandbox OU ID"
  type        = string
}

variable "approved_regions" {
  description = "List of approved regions for the organization"
  type        = list(string)
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
    default = {
    ManagedBy = "Terraform"
    Environment = "Governance"
    Project   = "AWS-Landing-Zone"
  }
}