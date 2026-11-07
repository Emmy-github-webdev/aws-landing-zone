
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
  default     = "10.10.0.0/16"
}

variable "production_vpc_cidr" {
  description = "Production VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "nonproduction_vpc_cidr" {
  description = "NonProduction VPC CIDR"
  type        = string
  default     = "10.30.0.0/16"
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

variable "common_tags" {
  description = "Common networking resource tags"
  type        = map(string)

  default = {
    ManagedBy = "Terraform"
    Project   = "AWS-Landing-Zone"
  }
}