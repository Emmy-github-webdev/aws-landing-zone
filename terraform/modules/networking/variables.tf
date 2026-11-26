variable "organization_id" {
  description = "AWS Organization ID"
  type        = string
}

variable "organization_arn" {
  description = "AWS Organization ARN used for RAM resource shares"
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

variable "enable_onpremises_vpn" {
  description = "Create a BGP Site-to-Site VPN from on-premises through the inspection VPC"
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_onpremises_vpn || var.enable_centralized_egress
    error_message = "On-premises VPN requires centralized egress and Network Firewall to be enabled."
  }
}

variable "onpremises_customer_gateway_ip" {
  description = "Static public IPv4 address of the on-premises VPN device"
  type        = string
  default     = ""

  validation {
    condition = (
      !var.enable_onpremises_vpn ||
      can(cidrnetmask("${var.onpremises_customer_gateway_ip}/32"))
    )
    error_message = "Set onpremises_customer_gateway_ip to the on-premises device's public IPv4 address when enabling the VPN."
  }
}

variable "onpremises_bgp_asn" {
  description = "On-premises BGP ASN used by the Customer Gateway and VPN"
  type        = number
  default     = 65000

  validation {
    condition     = var.onpremises_bgp_asn >= 1 && var.onpremises_bgp_asn <= 2147483647
    error_message = "onpremises_bgp_asn must be between 1 and 2147483647."
  }
}

variable "onpremises_cidrs" {
  description = "On-premises IPv4 prefixes advertised over BGP and routed through inspection"
  type        = list(string)
  default     = []

  validation {
    condition = (
      (!var.enable_onpremises_vpn || length(var.onpremises_cidrs) > 0) &&
      alltrue([for cidr in var.onpremises_cidrs : can(cidrnetmask(cidr))])
    )
    error_message = "When the on-premises VPN is enabled, provide at least one valid IPv4 CIDR in onpremises_cidrs."
  }
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
  default     = 365

  validation {
    condition = (
      var.dns_archive_retention_days > var.dns_archive_transition_days
    )

    error_message = "DNS archive retention must be greater than the Glacier transition period."
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
