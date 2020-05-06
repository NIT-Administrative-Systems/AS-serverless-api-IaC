resource "aws_apigatewayv2_api" "http_api" {
  name          = local.application_name
  protocol_type = "HTTP"

  target = aws_lambda_function.api.arn
  route_key = "$default"

  tags = local.tags
}

# API Gateway is allowed to invoke the Lambda
resource "aws_lambda_permission" "allow_http_api" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/$default"
}
