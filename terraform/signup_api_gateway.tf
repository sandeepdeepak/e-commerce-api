resource "aws_api_gateway_resource" "signup_proxy" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  parent_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.root_resource_id
  path_part   = "signup"
}

resource "aws_api_gateway_method" "signup_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id   = aws_api_gateway_resource.signup_proxy.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signup_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id = aws_api_gateway_method.signup_post_method.resource_id
  http_method = aws_api_gateway_method.signup_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.signup.invoke_arn
}

resource "aws_api_gateway_deployment" "signup_deploy" {
  depends_on = [
    aws_api_gateway_integration.signup_post_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  stage_name  = "prod"
}

