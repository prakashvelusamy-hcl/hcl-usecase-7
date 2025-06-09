terraform {
  backend "s3" {
    bucket  = "aws-state-s3"
    key     = var.state_file
    profile = "devops"
    region  = "ap-south-1"
    encrypt = true
  }
}
