terraform {
  backend "s3" {
    bucket       = "emmanuelogah-aws-lz-tfstate"
    key          = "landing-zone/governance/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}