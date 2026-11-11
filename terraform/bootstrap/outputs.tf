output "terraform_state_bucket" {
  description = "Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "Terraform state bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}