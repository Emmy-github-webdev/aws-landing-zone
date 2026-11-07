
resource "aws_accessanalyzer_analyzer" "organization" {
  count = var.enable_access_analyzer ? 1 : 0

  analyzer_name = "organization-access-analyzer"
  type          = "ORGANIZATION"

  tags = local.common_tags

  depends_on = [
    terraform_data.account_validation
  ]
}
