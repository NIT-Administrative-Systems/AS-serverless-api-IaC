# Admin Systems: Serverless API Infrastructure-as-Code
This is an Terraform IaC module for creating a serverless API using Lambda, HTTP APIs for Amazon API Gateway, and secrets management through SSM. It implements the Admin Systems practices outlines on our [cloud practice site](https://nit-administrative-systems.github.io/AS-CloudDocs/).

## Usage
This IaC module is appropriate if you're implementing a serverless API in Node. Your API should work within the limits imposed by API Gateway: no more than 30 seconds to fufill requests, and a maximum payload size of 10MB. Your API can utilize on-campus resources, like on-prem databases. You will be using Apigee to publish your API.

To use this IaC, you should create a new repository using the *TODO* template.

### Inputs
The following options can be passed in to the module:

| Input               | Required? | Purpose                                                      | Default            | 
|---------------------|-----------|--------------------------------------------------------------|--------------------| 
| app_name            | **Yes**   | Short name for your app                                      | *none*             | 
| environment         | **Yes**   | Short name for your app's environment                        | *none*             | 
| region              | **Yes**   | AWS region to build in                                       | *none*             | 
| source_dir          | **Yes**   | Source code directory                                        | *none*             | 
| source_zip_path     | **Yes**   | Path for the packaged (temporary) zip file                   | *none*             | 
| runtime_secrets     | **Yes**   | List of secret names for your app                            | []                 | 
| runtime_env         | **Yes**   | Map of env variables for your Lambda                         | {}                 | 
| lambda_vpc_id       | No        | Private network ID. Specify if accessing on-campus resources | *none*             | 
| lambda_subnet_ids   | No        | Network IP blocks. Specify if accessing on-campus resources  | []                 | 
| runtime_memory      | No        | Memory for Lambda runtime                                    | 128                | 
| runtime_version     | No        | Version of NodeJS to use                                     | nodejs12.x         | 
| runtime_timeout     | No        | Max runtime for a Lambda execution                           | 30                 | 
| log_retention_days  | No        | Retention period for CloudWatch logs                         | 14                 | 
| source_zip_excludes | No        | Files/folders to exclude from the source code zip file       | []                 | 
| lambda_handler      | No        | Lambda entry point                                           | serverless.handler | 

### Outputs
The following will be output from the module:

| Output               | Purpose                                                                                                             |
|----------------------|---------------------------------------------------------------------------------------------------------------------|
| `parameters`         | Secret SSM parameters. Output is used by Jenkins to set the secret text.                                            |
| `lambda_iam_role_id` | ID for an IAM role that you may add additional privileges to                                                        |
| `kms_arn`            | ID for the encryption key used for SSM secrets. You can use this key for other AWS services that can encrypt stuff. |
| `api_url`            | The URL for your API                                                                                                |