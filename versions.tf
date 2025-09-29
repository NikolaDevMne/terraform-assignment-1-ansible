terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket       = "nikola-vujisic-tfstate-eu-central-1"
    key          = "env/dev/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
