terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIAZZDC7R7ASXRYFYEN"
  secret_key = "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"
}
