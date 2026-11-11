
resource "aws_vpc" "infrastructure" {
  provider = aws.infrastructure

  cidr_block           = var.infrastructure_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.network_tags.infrastructure,
    {
      Name = "lz-infrastructure-vpc"
    }
  )
}

resource "aws_vpc" "production" {
  provider = aws.production

  cidr_block           = var.production_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.network_tags.production,
    {
      Name = "lz-production-vpc"
    }
  )
}

resource "aws_vpc" "nonproduction" {
  provider = aws.nonproduction

  cidr_block           = var.nonproduction_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.network_tags.nonproduction,
    {
      Name = "lz-nonproduction-vpc"
    }
  )
}