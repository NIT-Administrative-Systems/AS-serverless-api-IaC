resource "aws_kms_key" "key" {
  description = "Key for encrypting ${local.application_name} secrets"
  tags        = local.tags
}

resource "aws_ssm_parameter" "secure_param" {
  count = length(var.runtime_secrets)

  name        = "/${local.clean_app_name}/${var.environment}/${var.runtime_secrets[count.index]}"
  description = var.runtime_secrets[count.index]
  type        = "SecureString"
  value       = "SSM parameter store not populated from Jenkins"
  key_id      = aws_kms_key.key.arn

  tags = local.tags

  # The parameter will be created with a dummy value. Jenkins will update it with
  # the final value in a subsequent pipeline step.
  #
  # TF will not override the parameter once it has been created.
  lifecycle {
    ignore_changes = [value]
  }
}
