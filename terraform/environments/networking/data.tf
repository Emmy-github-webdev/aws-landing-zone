
data "terraform_remote_state" "organizations" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = "organizations/terraform.tfstate"
    region = var.state_region
  }
}