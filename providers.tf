terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20"
    }
    aap = {
      source  = "ansible/aap"
      version = "1.4.0-devpreview1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aap" {
}
