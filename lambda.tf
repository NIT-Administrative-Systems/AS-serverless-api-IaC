data "archive_file" "app_code_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  excludes    = concat([".build", ".github", ".jenkins", ".dependabot", ".git", ".env", "iac"], var.source_zip_excludes)

  output_path = var.source_zip_path
}

locals {
  lambda_add_vpc_settings = var.lambda_vpc_id == "" ? [] : [1]
}

resource "aws_lambda_function" "api" {
  function_name    = local.application_name
  role             = aws_iam_role.lambda_execution_role.arn

  s3_bucket        = aws_s3_bucket.app_code_bucket.id
  s3_key           = local.s3_zip_filename
  source_code_hash = data.archive_file.app_code_zip.output_md5

  handler     = var.lambda_handler
  memory_size = var.runtime_memory
  timeout     = var.runtime_timeout
  runtime     = var.runtime_version

  # The VPC config is optional; when it's not specified, this block will not be included.
  dynamic "vpc_config" {
    for_each = local.lambda_add_vpc_settings
    content {
      subnet_ids = var.lambda_subnet_ids
      security_group_ids = local.lambda_security_group_id
    }
  }

  environment {
    variables = merge(var.runtime_env, { SSM_SECRETS: join(",", aws_ssm_parameter.secure_param.*.name) })
  }

  tags = local.tags

  depends_on = [aws_s3_object.app_code_s3_upload]
}

# Log group name **MUST** match the Lambda's name
# This is just how Lambda works, you cannot overwrite/change the group your Lambda will log to.
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${local.application_name}"
  retention_in_days = var.log_retention_days
}

## S3 bucket for the Lambda zip
#-------------------------------
# You _can_ upload zip files directly to Lambda, but then they're limited to 50MB.
# This way, you get the full 250MB to play with.
resource "aws_s3_bucket" "app_code_bucket" {
  bucket = "${local.application_name}-code-deployment"

  tags = local.tags
}

resource "aws_s3_bucket_acl" "app_code_acl" {
  bucket = aws_s3_bucket.app_code_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "app_code_s3_upload" {
  bucket = aws_s3_bucket.app_code_bucket.id
  key    = local.s3_zip_filename
  source = var.source_zip_path
  etag   = data.archive_file.app_code_zip.output_md5
}
