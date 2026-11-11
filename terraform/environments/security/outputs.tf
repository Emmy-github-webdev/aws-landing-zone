
output "primary_guardduty_detector_id" {
  value = module.security_primary.guardduty_detector_id
}

output "secondary_guardduty_detector_id" {
  value = module.security_secondary.guardduty_detector_id
}

output "primary_access_analyzer_arn" {
  value = module.security_primary.access_analyzer_arn
}

output "secondary_access_analyzer_arn" {
  value = module.security_secondary.access_analyzer_arn
}

output "audit_bucket_name" {
  value = module.security_primary.audit_bucket_name
}

output "cloudtrail_arn" {
  value = module.security_primary.cloudtrail_arn
}

output "config_aggregator_arn" {
  value = module.security_primary.config_aggregator_arn
}
