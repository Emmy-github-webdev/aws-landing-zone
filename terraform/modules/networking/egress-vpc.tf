
resource "aws_vpc" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  cidr_block           = var.egress_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name    = "lz-central-egress-vpc"
      Purpose = "CentralizedTrafficInspection"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_internet_gateway" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  vpc_id = aws_vpc.egress[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "lz-central-egress-igw"
    }
  )
}
