provider "aws" {
  alias  = "main"
  region = "us-east-1"
}

data "terraform_remote_state" "remote_state" {
  backend = "s3"

  config {
    bucket  = "yourls-tfstate"
    key     = "yourls-dev/terraform.tfstate"
    encrypt = "true"

    # region = "us-east-1"
  }
}

terraform {
  backend "s3" {
    bucket  = "yourls-tfstate"
    key     = "yourls-dev/terraform.tfstate"
    encrypt = "true"
    region  = "us-east-1"
  }
}
