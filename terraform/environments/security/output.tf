output "security_account_id" {
  value = module.security.security_account_id
}

output "guardduty_detector_ids" {
  value = module.security.guardduty_detector_ids
}

output "securityhub_account_ids" {
  value = module.security.securityhub_account_ids
}

output "config_aggregator_arn" {
  value = module.security.config_aggregator_arn
}

output "cloudtrail_arn" {
  value = module.security.cloudtrail_arn
}