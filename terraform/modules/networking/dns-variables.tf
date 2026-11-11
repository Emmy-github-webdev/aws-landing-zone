
variable "enable_dns_security" {
  description = "Enable DNS Firewall and Resolver infrastructure"
  type        = bool
  default     = true
}

variable "dns_resolver_subnet_ids" {
  description = "Private Infrastructure VPC subnets for Resolver endpoints, one per AZ"
  type        = list(string)
  default     = []
}

variable "dns_onpremises_resolver_ips" {
  description = "On-premises DNS servers used for conditional forwarding"
  type        = list(string)
  default     = []
}

variable "dns_private_domain" {
  description = "Private DNS domain forwarded to on-premises DNS"
  type        = string
}

variable "dns_firewall_blocked_domains" {
  description = "Domains blocked by DNS Firewall"
  type        = list(string)
}

variable "dns_firewall_allowed_domains" {
  description = "Domains explicitly allowed by DNS Firewall"
  type        = list(string)
  default     = []
}

variable "dns_firewall_default_action" {
  description = "Default action for DNS Firewall"
  type        = string
  default     = "ALLOW"

  validation {
    condition = contains(
      ["ALLOW", "ALERT"],
      var.dns_firewall_default_action
    )

    error_message = "DNS Firewall default action must be ALLOW or ALERT."
  }
}

variable "dns_log_retention_days" {
  description = "DNS query log retention in days"
  type        = number
  default     = 90
}

variable "dns_allowed_query_cidrs" {
  description = "CIDRs permitted to query central inbound Resolver endpoints"
  type        = list(string)
  default     = []
}

variable "dns_onpremises_cidrs" {
  description = "On-premises networks permitted to access DNS services"
  type        = list(string)
  default     = []
}

variable "organization_arn" {
  description = "AWS Organization ARN used for RAM sharing"
  type        = string
}