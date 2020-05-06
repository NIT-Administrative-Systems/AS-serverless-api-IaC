data "archive_file" "app_code_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  excludes    = concat([".build", ".github", ".jenkins", ".dependabot", ".git", ".env", "iac"], var.source_zip_excludes)

  output_path = var.source_zip_path
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

  # NOTE: if both subnet_ids and security_group_ids are empty then vpc_config is considered to be empty or unset.
  # In other words: this will make a Lambda on AWS' network if we leave both values blank.
  vpc_config {
    subnet_ids = length(var.lambda_subnet_ids) == 0 ? null : var.lambda_subnet_ids
    security_group_ids = local.lambda_security_group_id
  }

  environment {
    variables = merge(var.runtime_env, { SSM_SECRETS: join(",", aws_ssm_parameter.secure_param.*.name) })
  }

  tags = local.tags

  depends_on = [aws_s3_bucket_object.app_code_s3_upload]
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
  acl    = "private"

  tags = local.tags
}

resource "aws_s3_bucket_object" "app_code_s3_upload" {
  bucket = aws_s3_bucket.app_code_bucket.id
  key    = local.s3_zip_filename
  source = var.source_zip_path
  etag   = data.archive_file.app_code_zip.output_md5
}
