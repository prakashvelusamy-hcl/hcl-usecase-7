terraform {
  backend "s3" {
    bucket  = "aws-state-s3"
    key     = "state/${terraform.workspace}/terraform.tfstate"
    profile = "devops"
    region  = "ap-south-1"
    encrypt = true
  }
}
