primary_region             = "us-east-1"
dns_archive_retention_days = 365
availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]
egress_vpc_cidr                = "10.0.0.0/16"
infrastructure_vpc_cidr        = "10.10.0.0/16"
production_vpc_cidr            = "10.20.0.0/16"
nonproduction_vpc_cidr         = "10.30.0.0/16"
enable_onpremises_vpn          = true
onpremises_customer_gateway_ip = "77.161.123.205"
onpremises_bgp_asn             = 65000
onpremises_cidrs               = ["192.168.2.0/24"]
availability_zone_ids = [
  "use1-az1",
  "use1-az2",
  "use1-az4"
]
firewall_log_retention_days = 90
firewall_allowed_tcp_ports = [
  80,
  443
]
firewall_allowed_udp_ports = [
  53
]
firewall_home_net_cidrs = [
  "10.10.0.0/16",
  "10.20.0.0/16",
  "10.30.0.0/16"
]

terraform_state_bucket = "emmanuelogah-aws-lz-tfstate"
state_region           = "us-east-1"
logging_account_id     = "787461921629"