output "aws_apigatewayv2_arn" {
    value = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
output "api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}