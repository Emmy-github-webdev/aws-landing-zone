resource "awscc_controltower_landing_zone" "banking" {
  manifest = jsonencode({
    governedRegions = [
      "us-east-1",
      "us-west-2"
    ]

    organizationStructure = {
      security = {
        name = "Security"
      }

      sandbox = {
        name = "Sandbox"
      }
    }

    centralizedLogging = {
      enabled   = true

      configurations = {
        loggingBucket = {
          retentionDays = 365
        }

        accessLoggingBucket = {
          retentionDays = 365
        }
      }
    }

    securityRoles = {
    }

    accessManagement = {
      enabled = true
    }
  })

  version = var.control_tower_version

  lifecycle {
    prevent_destroy = true
  }
}