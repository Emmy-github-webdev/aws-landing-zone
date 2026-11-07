# Create Infrastructure for AWS Organizations Unit
resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = {
    Name      = "Infrastructure"
    ManagedBy = "Terraform"
    Purpose   = "Shared Infrastructure"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create Workloads for AWS Organizations Unit
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = {
    Name      = "Workloads"
    ManagedBy = "Terraform"
    Purpose   = "Application Workloads"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create Child OU for Workload AWS Organizations Unit: production OU
resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Name        = "Production"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create Child OU for Workload AWS Organizations Unit: nonproduction OU
resource "aws_organizations_organizational_unit" "nonproduction" {
  name      = "NonProduction"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Name        = "NonProduction"
    Environment = "NonProduction"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}