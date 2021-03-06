

data "archive_file" "lambda_zip_signup" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_signup.zip"
  source_dir  = "functions/signup"
}

resource "aws_lambda_function" "signup" {
  function_name = "SignupTerraform"

  filename = data.archive_file.lambda_zip_signup.output_path

  # # The bucket name as created earlier with "aws s3api create-bucket"
  # s3_bucket = "terraform-serverless-example17121996"
  # s3_key    = "v1.0.0/signup.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.handler"
  runtime = "nodejs10.x"

  environment {
    variables = {
      userPoolId  = aws_cognito_user_pool.pool.id
      appClientId = aws_cognito_user_pool_client.client.id
    }
  }

  role = aws_iam_role.post_signup_lambda_exec.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "post_signup_lambda_exec" {
  name = "savesignups_lambda"

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

resource "aws_iam_role_policy_attachment" "post_signup_policy" {
  role       = aws_iam_role.post_signup_lambda_exec.name
  policy_arn = aws_iam_policy.post_signup_cognito_access.arn
}

# access cognito.
resource "aws_iam_policy" "post_signup_cognito_access" {
  name        = "post_signup_cognito_access"
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

resource "aws_lambda_permission" "post_signup_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.e_commerce_api_terraform.execution_arn}/*/*"
}

