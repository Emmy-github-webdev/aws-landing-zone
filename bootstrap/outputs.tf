# Outputs

output "organization_id" {
  value = aws_organizations_organization.org.id
}

output "root_id" {
  value = aws_organizations_organization.org.roots[0].id
}

output "organizational_units" {
  value = {
    for name, ou in aws_organizations_organizational_unit.ou :
    name => ou.id
  }
}

output "accounts" {
  value = {
    for name, account in aws_organizations_account.accounts :
    name => account.id
  }
}