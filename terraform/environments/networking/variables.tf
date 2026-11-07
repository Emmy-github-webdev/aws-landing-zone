
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
