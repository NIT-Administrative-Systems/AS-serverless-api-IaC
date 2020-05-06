variable "app_name" {
    description = "Short name for your app. Used in naming/tagging resources."
}

variable "environment" {
    description = "Short name for your app's environment. Used in naming/tagging resources."
}

variable "region" {
    description = "AWS region to build resources in"
}

variable "runtime_secrets" {
  description = "Secrets to create in SSM for Jenkins to populate"
  type = list(string)
}

variable "runtime_env" {
  description = "Environment variables to provide to the AWS Lambda runtime"
  type = map(string)
}

# Has sane defaults, probably don't need to set these yourself
variable "runtime_version" {
    description = "AWS Lambda runtime to use"
    default = "nodejs12.x"
}

variable "runtime_memory" {
    description = "Memory to give the Lambda runtime, in MB"
    default = 128
}

variable "runtime_timeout" {
    description = "Timeout for Lambda handler in seconds"
    default = 30 # not much sense in increasing it beyond this; API Gateway will time out instead (hard limit)
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs, in days"
  default = 14
}

variable "source_dir" {
  description = "Source code directory, relative to base module"
}

variable "source_zip_path" {
  description = "Path to the prepared (temporary) zip file, relative to the base module"
}

variable "source_zip_excludes" {
  description = "Set of files/dirs to exclude from the Lambda package, beyond the standard set."
  type        = list(string)
  default     = []
}

variable "lambda_handler" {
  description = "Handler for your Lambda"
  default = "serverless.handler"
}

## Lambda VPC Settings
# ---------------------
variable "lambda_vpc_id" {
  description = "VPC ID for a Lambda that runs inside the Northwestern VPC. Must be specified if lambda_subnet_ids is."
  default = ""
}

variable "lambda_subnet_ids" {
  description = "Subnet IDs for a Lambda that runs inside the Northwestern VPC. Must be specified if lambda_vpc_id is."
  type = list(string)
  default = []
}
