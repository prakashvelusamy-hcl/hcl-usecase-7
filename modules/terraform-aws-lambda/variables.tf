variable "private_subnet_id" {
    description = "private_subnet_id"
    type = list(string)
}
variable "vpc_id" {
    description = "the main vpc ID"
    type = string
}
variable "aws_apigatewayv2_arn" {
    description = "aws_apigatewayv2_arn"
    type = string
}
