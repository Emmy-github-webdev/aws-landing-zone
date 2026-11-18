resource "aws_ssoadmin_account_assignment" "network_troubleshooters" {
  for_each = var.network_account_ids

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_troubleshooter.arn

  principal_id   = aws_identitystore_group.network_troubleshooters.group_id
  principal_type = "GROUP"

  target_id   = each.value
  target_type = "AWS_ACCOUNT"
}