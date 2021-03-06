

data "archive_file" "lambda_zip_login" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_login.zip"
  source_dir  = "functions/login"
}

resource "aws_lambda_function" "login" {
  function_name = "LoginTerraform"

  filename         = data.archive_file.lambda_zip_login.output_path
  source_code_hash = data.archive_file.lambda_zip_login.output_base64sha256

  # The bucket name as created earlier with "aws s3api create-bucket"
  # s3_bucket = "terraform-serverless-example17121996"
  # s3_key    = "v1.0.0/login.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.handler"
  runtime = "nodejs10.x"
  timeout = 20

  environment {
    variables = {
      userPoolId  = aws_cognito_user_pool.pool.id
      appClientId = aws_cognito_user_pool_client.client.id
    }
  }

  role = aws_iam_role.post_login_lambda_exec.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "post_login_lambda_exec" {
  name = "savelogins_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "post_login_policy" {
  role       = aws_iam_role.post_login_lambda_exec.name
  policy_arn = aws_iam_policy.post_login_cognito_access.arn
}

# access cognito.
resource "aws_iam_policy" "post_login_cognito_access" {
  name        = "post_login_cognito_access"
  path        = "/"
  description = "IAM policy for accessing cognito"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "cognito-idp:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "post_login_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.e_commerce_api_terraform.execution_arn}/*/*"
}

