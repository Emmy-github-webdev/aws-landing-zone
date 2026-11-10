variable "organization_id" {
  description = "AWS Organization ID"
  type        = string
}

variable "infrastructure_account_id" {
  description = "Infrastructure account ID"
  type        = string
}

variable "production_account_id" {
  description = "Production account ID"
  type        = string
}

variable "nonproduction_account_id" {
  description = "NonProduction account ID"
  type        = string
}

variable "primary_region" {
  description = "Primary networking region"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used by the network"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "infrastructure_vpc_cidr" {
  description = "Infrastructure VPC CIDR"
  type        = string
}

variable "production_vpc_cidr" {
  description = "Production VPC CIDR"
  type        = string
}

variable "nonproduction_vpc_cidr" {
  description = "NonProduction VPC CIDR"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Create NAT gateways for workload VPCs"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway instead of one per AZ"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Enable S3 gateway endpoint"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB gateway endpoint"
  type        = bool
  default     = true
}

variable "enable_ssm_endpoints" {
  description = "Enable Systems Manager interface endpoints"
  type        = bool
  default     = true
}

variable "policy_tags" {
  description = "Common networking resource tags"
  type        = map(string)
}


variable "dns_archive_retention_days" {
  description = "Approved S3 Object Lock compliance retention period"
  type        = number

  validation {
    condition = (
      var.dns_archive_retention_days >= 90 &&
      var.dns_archive_retention_days <= 36500
    )

    error_message = "DNS archive retention must be between 90 and 36500 days."
  }
}

variable "dns_archive_transition_days" {
  description = "Days before DNS archive objects transition to Glacier Flexible Retrieval"
  type        = number
  default     = 90

  validation {
    condition     = var.dns_archive_transition_days >= 90
    error_message = "Glacier Flexible Retrieval transition must be at least 90 days."
  }
}
