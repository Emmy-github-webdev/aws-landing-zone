resource "aws_kinesis_stream" "central_dns" {
  provider = aws.logging

  name             = "lz-central-dns-logs"
  retention_period = 168

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"

  tags = merge(
    local.common_tags,
    {
      Name    = "lz-central-dns-logs"
      Purpose = "Central DNS audit logging"
    }
  )
}

data "aws_caller_identity" "logging" {
  provider = aws.logging
}

data "aws_region" "logging" {
  provider = aws.logging
}

resource "aws_iam_role" "central_dns_logs" {
  provider = aws.logging

  name = "lz-central-dns-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "logs.${data.aws_region.logging.name}.amazonaws.com"
      }

      Action = "sts:AssumeRole"

      Condition = {
        StringLike = {
          "aws:SourceArn" = "arn:aws:logs:${data.aws_region.logging.name}:${data.aws_caller_identity.logging.account_id}:*"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "central_dns_logs" {
  provider = aws.logging

  name = "lz-central-dns-kinesis-write"
  role = aws_iam_role.central_dns_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ]

      Resource = aws_kinesis_stream.central_dns.arn
    }]
  })
}

resource "aws_cloudwatch_log_destination" "central_dns" {
  provider = aws.logging

  name       = "lz-central-dns-destination"
  role_arn   = aws_iam_role.central_dns_logs.arn
  target_arn = aws_kinesis_stream.central_dns.arn
}

resource "aws_cloudwatch_log_destination_policy" "central_dns" {
  provider = aws.logging

  destination_name = aws_cloudwatch_log_destination.central_dns.name

  access_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "AllowLandingZoneDNSLogAccounts"
      Effect = "Allow"

      Principal = {
        AWS = [
          var.infrastructure_account_id,
          var.production_account_id,
          var.nonproduction_account_id
        ]
      }

      Action = [
        "logs:PutSubscriptionFilter"
      ]

      Resource = aws_cloudwatch_log_destination.central_dns.arn
    }]
  })
}