# Role for the Lambda to assume
resource "aws_iam_role" "lambda_execution_role" {
  name               = "${local.application_name}-lambda-execution"
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role.json
  description        = "${local.application_name} Lambda Execution Role"
}

# Boilterplate-y policy that allows Lambda to assume this role
data "aws_iam_policy_document" "lambda_execution_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

# The meat of the Lambda
data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.lambda_log_group.arn}:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DetachNetworkInterface",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "ssm:GetParameter"]
    resources = aws_ssm_parameter.secure_param.*.arn
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.key.arn]
  }
}

resource "aws_iam_role_policy" "lambda_kms_policy" {
  name   = "${local.application_name}-lambda-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

## Security Group for Lambda in VPC
# ---------------------------------
resource "aws_security_group" "api_rules" {
  count = var.lambda_vpc_id == "" ? 0 : 1

  name        = "${local.application_name}-lambda-SG"
  description = "Allows output traffic but no inbound -- requests come from API Gateway"
  vpc_id      = var.lambda_vpc_id

  # No ingress -- block everything, only API Gateway should be talking to this.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

locals {
  lambda_security_group_id = var.lambda_vpc_id == "" ? null : [aws_security_group.api_rules[0].id]
}
