locals {
    # Remove any unaccaptable chars since we'll be using this for resource name
    clean_app_name = lower(replace(var.app_name, "/[^A-Za-z0-9_-]/", "-"))

    # Keep the app name shorter so we can be sure {app name}-{env} fits in all the resource names.
    application_name = lower("${substr(local.clean_app_name, 0, max(length(local.clean_app_name), 40))}-${var.environment}")

    s3_zip_filename = "${local.application_name}.zip"

    tags = {
        Application = var.app_name
        Environment = var.environment
    }
}
