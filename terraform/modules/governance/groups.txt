
resource "aws_identitystore_group" "network_troubleshooters" {
  identity_store_id = local.identity_store_id

  display_name = "Network-Troubleshooters"

  description = "Read-only network troubleshooting across AWS Landing Zone accounts"
}
