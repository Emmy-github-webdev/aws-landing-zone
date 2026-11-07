data "aws_caller_identity" "infrastructure" {
  provider = aws.infrastructure
}

data "aws_caller_identity" "production" {
  provider = aws.production
}

data "aws_caller_identity" "nonproduction" {
  provider = aws.nonproduction
}

data "aws_availability_zones" "available" {
  provider = aws.infrastructure

  state = "available"
}