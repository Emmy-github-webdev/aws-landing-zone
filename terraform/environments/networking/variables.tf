variable "common_tags" {
  description = "Common networking resource tags"
  type        = map(string)

  default = {
    ManagedBy = "Terraform"
    Environment="Networking"
    Project   = "AWS-Landing-Zone"
  }
}

variable "enable_centralized_egress" {
  description = "Enable centralized egress and inspection"
  type        = bool
  default     = true
}

variable "egress_vpc_cidr" {
  description = "Centralized egress VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_ids" {
  description = "Availability Zone IDs shared by participating accounts"
  type        = list(string)
}

variable "firewall_log_retention_days" {
  type    = number
  default = 90
}

variable "firewall_allowed_tcp_ports" {
  type    = list(number)
  default = [80, 443]
}

variable "firewall_allowed_udp_ports" {
  type    = list(number)
  default = [53]
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

variable "dns_resolver_subnet_ids" {
  description = "Infrastructure VPC private subnet IDs for DNS Resolver endpoints"
  type        = list(string)
}

variable "dns_onpremises_resolver_ips" {
  description = "Corporate DNS server IP addresses"
  type        = list(string)
  default     = []
}

variable "dns_private_domain" {
  description = "Corporate private DNS domain"
  type        = string
  default     = "corp.example.com"
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

variable "organization_arn" {
  description = "AWS Organization ARN"
  type        = string
}

variable "logging_role_arn" {
  description = "IAM role ARN for the Logging account"
  type        = string
}

variable "logging_account_id" {
  description = "AWS Logging account ID"
  type        = string
}

variable "infrastructure_account_id" {
  description = "AWS Infrastructure account ID"
  type        = string
}

variable "production_account_id" {
  description = "AWS Production account ID"
  type        = string
}

variable "nonproduction_account_id" {
  description = "AWS NonProduction account ID"
  type        = string
}