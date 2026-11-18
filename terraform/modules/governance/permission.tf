
resource "aws_ssoadmin_permission_set" "network_troubleshooter" {
  name        = "NetworkTroubleshooter"
  description = "Read-only network troubleshooting across Landing Zone accounts"

  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"

  tags = var.policy_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "network_troubleshooter" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_troubleshooter.arn

  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}
