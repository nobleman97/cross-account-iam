
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "account_b"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_b_id}:role/terraform"
  }
}

