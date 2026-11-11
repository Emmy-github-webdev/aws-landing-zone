primary_region="us-east-1"
dns_archive_retention_days=90
availability_zones=[
  "us-east-1a", 
  "us-east-1b", 
  "us-east-1c", 
  "us-west-1a", 
  "us-west-1b", 
  "us-west-1c"
]
egress_vpc_cidr="10.0.0.0/16"
infrastructure_vpc_cidr = "10.10.0.0/16"
production_vpc_cidr= "10.20.0.0/16"
nonproduction_vpc_cidr = "10.30.0.0/16"
availability_zone_ids=[
  "use1-az1",
  "use1-az2",
  "use1-az3",
  "usw2-az1",
  "usw2-az2",
  "usw2-az3"
]
firewall_log_retention_days=90
firewall_allowed_tcp_ports=[
  80,
  443
]
firewall_allowed_udp_ports=[
  53
]