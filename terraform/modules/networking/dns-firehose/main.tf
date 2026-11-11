
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "firehose_delivery" {
  name = "lz-dns-firehose-delivery"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "firehose.amazonaws.com"
      }

      Action = "sts:AssumeRole"

      Condition = {
        StringEquals = {
          "sts:ExternalId" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })

  tags = var.common_tags

  lifecycle {
    precondition {
      condition = (
        data.aws_caller_identity.current.account_id ==
        var.source_account_id
      )

      error_message = "Firehose is being deployed into the wrong AWS account."
    }
  }
}

resource "aws_iam_role_policy" "firehose_s3" {
  name = "lz-dns-firehose-s3-access"
  role = aws_iam_role.firehose_delivery.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "BucketMetadata"
        Effect = "Allow"

        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]

        Resource = var.destination_bucket_arn
      },
      {
        Sid    = "WriteDNSArchive"
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]

        Resource = "${var.destination_bucket_arn}/${var.destination_prefix}*"
      }
    ]
  })
}


resource "aws_kinesis_firehose_delivery_stream" "dns" {
  name        = "lz-dns-${var.source_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_delivery.arn
    bucket_arn = var.destination_bucket_arn

    prefix = "${var.destination_prefix}year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    error_output_prefix = "dns/errors/${var.source_name}/!{firehose:error-output-type}/"

    buffering_size     = 5
    buffering_interval = 300

    compression_format = "GZIP"

    processing_configuration {
      enabled = true

      # Decompress CloudWatch Logs GZIP envelope.
      processors {
        type = "Decompression"

        parameters {
          parameter_name  = "CompressionFormat"
          parameter_value = "GZIP"
        }
      }

      # Extract actual log messages from CloudWatch Logs.
      processors {
        type = "CloudWatchLogProcessing"

        parameters {
          parameter_name  = "DataMessageExtraction"
          parameter_value = "true"
        }
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "lz-dns-${var.source_name}"
      Environment = var.source_name
      Purpose     = "Central DNS audit delivery"
    }
  )

  depends_on = [
    aws_iam_role_policy.firehose_s3
  ]
}


resource "aws_iam_role" "cloudwatch_to_firehose" {
  name = "lz-dns-cloudwatch-to-firehose"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "logs.${data.aws_region.current.name}.amazonaws.com"
      }

      Action = "sts:AssumeRole"

      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }

        ArnLike = {
          "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.source_log_group_name}:*"
        }
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "cloudwatch_to_firehose" {
  name = "lz-dns-cloudwatch-firehose-write"
  role = aws_iam_role.cloudwatch_to_firehose.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ]

      Resource = aws_kinesis_firehose_delivery_stream.dns.arn
    }]
  })
}


resource "aws_cloudwatch_log_subscription_filter" "dns" {
  name            = "lz-dns-central-archive"
  log_group_name  = var.source_log_group_name
  destination_arn = aws_kinesis_firehose_delivery_stream.dns.arn

  role_arn       = aws_iam_role.cloudwatch_to_firehose.arn
  filter_pattern = ""

  depends_on = [
    aws_iam_role_policy.cloudwatch_to_firehose
  ]
}
