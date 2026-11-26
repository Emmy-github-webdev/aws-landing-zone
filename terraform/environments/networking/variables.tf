variable "common_tags" {
  description = "Common networking resource tags"
  type        = map(string)

  default = {
    ManagedBy   = "Terraform"
    Environment = "Networking"
    Project     = "AWS-Landing-Zone"
  }
}

variable "primary_region" {
  description = "Primary AWS region for networking resources"
  type        = string
}

variable "dns_archive_retention_days" {
  description = "DNS query log archive retention in days"
  type        = number
}
variable "enable_centralized_egress" {
  description = "Enable centralized egress and inspection"
  type        = bool
  default     = true
}

variable "enable_onpremises_vpn" {
  description = "Create a BGP Site-to-Site VPN from on-premises through Network Firewall"
  type        = bool
  default     = false
}

variable "onpremises_customer_gateway_ip" {
  description = "Static public IPv4 address of the on-premises VPN device"
  type        = string
  default     = ""
}

variable "onpremises_bgp_asn" {
  description = "On-premises BGP ASN used by the Customer Gateway and VPN"
  type        = number
  default     = 65000
}

variable "onpremises_cidrs" {
  description = "On-premises IPv4 prefixes advertised over BGP and routed through inspection"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Availability Zones shared across the participating accounts"
  type        = list(string)
}

variable "egress_vpc_cidr" {
  description = "Centralized egress VPC CIDR"
  type        = string
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

variable "availability_zone_ids" {
  description = "Availability Zone IDs shared by participating accounts"
  type        = list(string)
}

variable "firewall_log_retention_days" {
  type = number
}

variable "firewall_allowed_tcp_ports" {
  type = list(number)
}

variable "firewall_allowed_udp_ports" {
  type = list(number)
}

variable "firewall_home_net_cidrs" {
  description = "Internal CIDRs protected by the firewall"
  type        = list(string)
}


variable "enable_dns_security" {
  description = "Enable centralized DNS Resolver and DNS Firewall"
  type        = bool
  default     = true
}

variable "dns_onpremises_resolver_ips" {
  description = "Corporate DNS server IP addresses"
  type        = list(string)
  default     = []
}

variable "dns_private_domain" {
  description = "Corporate private DNS domain"
  type        = string
  default     = ""

  validation {
    condition = (
      length(var.dns_onpremises_resolver_ips) == 0 ||
      length(var.dns_private_domain) > 0
    )
    error_message = "Set dns_private_domain when dns_onpremises_resolver_ips is configured."
  }
}

variable "dns_firewall_blocked_domains" {
  description = "Blocked DNS domains"
  type        = list(string)
  default     = []
}

variable "dns_allowed_query_cidrs" {
  description = "Approved CIDRs for inbound DNS queries"
  type        = list(string)
  default     = []
}

variable "dns_onpremises_cidrs" {
  description = "On-premises networks"
  type        = list(string)
  default     = []
}

variable "dns_log_retention_days" {
  description = "DNS log retention period"
  type        = number
  default     = 90
}

variable "logging_account_id" {
  description = "AWS Logging account ID"
  type        = string
}

variable "terraform_state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

variable "state_region" {
  description = "AWS terraform state region"
  type        = string
}
