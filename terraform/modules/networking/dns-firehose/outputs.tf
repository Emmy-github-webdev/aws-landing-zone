output "firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.dns.arn
}

output "firehose_stream_name" {
  value = aws_kinesis_firehose_delivery_stream.dns.name
}

output "firehose_delivery_role_arn" {
  value = aws_iam_role.firehose_delivery.arn
}

output "subscription_filter_name" {
  value = aws_cloudwatch_log_subscription_filter.dns.name
}