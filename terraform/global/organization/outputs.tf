output "organization_id" {
  value = aws_organizations_organization.banking.id
}

output "organization_arn" {
  value = aws_organizations_organization.banking.arn
}

output "root_id" {
  value = aws_organizations_organization.banking.roots[0].id
}