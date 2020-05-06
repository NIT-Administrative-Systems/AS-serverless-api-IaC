output "parameters" {
  description = "SSM secret names for Jenkins to sync"
  value       = zipmap(var.runtime_secrets, slice(aws_ssm_parameter.secure_param.*.name, 0, length(var.runtime_secrets)))
}

output "lambda_iam_role_id" {
  description = "Lambda's IAM role ID. You can attach additional policies to this role to utilize other AWS services not handled by the API module"
  value       = aws_iam_role.lambda_execution_role.id
}

output "api_url" {
  description = "The API URL"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "kms_arn" {
  description = "AWS KMS key ID used to encrypt secrets, in case you wish to use it with other services."
  value       = aws_kms_key.key.arn
}
