variable "expected_organization_id" {
  type = string
}

variable "sandbox_ou_id" {
  description = "Existing Sandbox OU ID"
  type        = string
}

variable "approved_regions" {
  description = "List of approved regions for the organization"
  type        = list(string)
}