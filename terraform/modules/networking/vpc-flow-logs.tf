
resource "aws_cloudwatch_log_group" "infrastructure_flow_logs" {
  provider = aws.infrastructure
  count    = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/infrastructure/flow-logs"
  retention_in_days = 90

  tags = local.network_tags.infrastructure
}

resource "aws_iam_role" "infrastructure_flow_logs" {
  provider = aws.infrastructure
  count    = var.enable_flow_logs ? 1 : 0

  name = "InfrastructureVpcFlowLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.network_tags.infrastructure
}

resource "aws_iam_role_policy" "infrastructure_flow_logs" {
  provider = aws.infrastructure
  count    = var.enable_flow_logs ? 1 : 0

  role = aws_iam_role.infrastructure_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "${aws_cloudwatch_log_group.infrastructure_flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "infrastructure" {
  provider = aws.infrastructure
  count    = var.enable_flow_logs ? 1 : 0

  vpc_id = aws_vpc.infrastructure.id

  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"

  log_destination = aws_cloudwatch_log_group.infrastructure_flow_logs[0].arn
  iam_role_arn    = aws_iam_role.infrastructure_flow_logs[0].arn

  tags = local.network_tags.infrastructure
}
