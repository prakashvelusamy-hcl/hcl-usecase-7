resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_policy" "lambda_ecr_policy" {
  name        = "LambdaECRImagePullPolicy_1"
  description = "Allows Lambda to pull Docker image from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "LambdaECRImagePullAccess",
        Effect : "Allow",
        Action : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
         "logs:PutLogEvents",
          "xray:PutTelemetryRecords",
          "xray:PutTraceSegments"
        ],
        Resource : "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.lambda_exec.name
  #   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  policy_arn = aws_iam_policy.lambda_ecr_policy.arn
}
resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lambda_function" "docker_lambda" {
  function_name = "my-docker-lambda"
  package_type = "Image"
  image_uri = "495599733393.dkr.ecr.ap-south-1.amazonaws.com/my-app:v1"
  role = aws_iam_role.lambda_exec.arn
  timeout     = 30
  memory_size = 128
  vpc_config {
    subnet_ids         = var.private_subnet_id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  tracing_config {
    mode = "Active"
  }
}


resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = var.aws_apigatewayv2_arn
}


resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/lambda-http-api"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/my-docker-lambda"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Docker-Lambda-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ApiGateway",
              "4XXError",
              "ApiName",
              "lambda-http-api"
            ],
            [
              "AWS/ApiGateway",
              "5XXError",
              "ApiName",
              "lambda-http-api"
            ]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-south-1"
          title  = "API Gateway Errors"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              "my-docker-lambda"
            ],
            [
              "AWS/Lambda",
              "Throttles",
              "FunctionName",
              "my-docker-lambda"
            ]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Lambda Errors/Throttles"
        }
      }
    ]
  })
}
