
variable "enable_centralized_egress" {
  description = "Enable centralized egress infrastructure"
  type        = bool
  default     = true
}

variable "egress_vpc_cidr" {
  description = "CIDR for centralized inspection VPC"
  type        = string
}

variable "egress_firewall_subnet_newbits" {
  description = "Additional subnet bits for firewall subnets"
  type        = number
  default     = 8
}

variable "egress_tgw_subnet_newbits" {
  description = "Additional subnet bits for TGW attachment subnets"
  type        = number
  default     = 8
}

variable "egress_public_subnet_newbits" {
  description = "Additional subnet bits for public NAT subnets"
  type        = number
  default     = 8
}

variable "egress_nat_gateway_per_az" {
  description = "Create one NAT Gateway per Availability Zone"
  type        = bool
  default     = true
}

variable "firewall_log_retention_days" {
  description = "CloudWatch firewall log retention"
  type        = number
}

variable "firewall_allowed_tcp_ports" {
  description = "Allowed outbound TCP ports"
  type        = list(number)
}

variable "firewall_allowed_udp_ports" {
  description = "Allowed outbound UDP ports"
  type        = list(number)
}

variable "availability_zone_ids" {
  description = "Availability Zone IDs shared across the participating accounts"
  type        = list(string)

  validation {
    condition     = length(var.availability_zone_ids) >= 2
    error_message = "At least two Availability Zone IDs are required."
  }
}

variable "firewall_home_net_cidrs" {
  description = "Internal CIDRs protected by the firewall"
  type        = list(string)
}