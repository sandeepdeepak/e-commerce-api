
data "archive_file" "lambda_zip_presignup" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_presignup.zip"
  source_dir  = "functions/presignup"
}

resource "aws_lambda_function" "presignup" {
  function_name = "PreSignupTerraform"

  filename         = data.archive_file.lambda_zip_presignup.output_path
  source_code_hash = data.archive_file.lambda_zip_presignup.output_base64sha256

  # # The bucket name as created earlier with "aws s3api create-bucket"
  # s3_bucket = "terraform-serverless-example17121996"
  # s3_key    = "v1.0.0/presignup.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.post_presignup_lambda_exec.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "post_presignup_lambda_exec" {
  name = "savepresignups_lambda"

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

resource "aws_lambda_permission" "post_presignup_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presignup.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.e_commerce_api_terraform.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_execution_from_user_pool" {
  statement_id  = "AllowExecutionFromUserPool"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presignup.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.pool.arn
}

