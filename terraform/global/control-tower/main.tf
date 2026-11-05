resource "aws_controltower_landing_zone" "banking" {
manifest_json = file("${path.module}/LandingZoneManifest.json")

  version = var.control_tower_version

  # lifecycle {
  #   prevent_destroy = true
  # }
}