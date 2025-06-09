
module "vpc" {
  source         = "./modules/terraform-aws-vpc"
  vpc_cidr       = var.vpc_cidr
  pub_sub_count  = var.pub_sub_count
  priv_sub_count = var.priv_sub_count
  nat_count      = var.nat_count
  env            = var.env
}

module "lambda" {
  source = "./modules/terraform-aws-lambda"
  private_subnet_id = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
  aws_apigatewayv2_arn = module.api_gateway.aws_apigatewayv2_arn
  }

module "api_gateway" {
  source = "./modules/terraform-aws-apigateway"
  integration_uri_arn = module.lambda.integration_uri_arn
}