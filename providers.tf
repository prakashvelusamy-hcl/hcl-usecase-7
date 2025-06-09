terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # Pin to the latest 4.x version, or change to a specific version like "4.10.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "devops"

