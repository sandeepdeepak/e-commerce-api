resource "aws_api_gateway_rest_api" "e_commerce_api_terraform" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  parent_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_method" "item_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "item_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_gateway_authorizer.id
}

resource "aws_api_gateway_integration" "item_get_lambda" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id = aws_api_gateway_method.item_get_method.resource_id
  http_method = aws_api_gateway_method.item_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getItems.invoke_arn
}

resource "aws_api_gateway_integration" "item_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id = aws_api_gateway_method.item_post_method.resource_id
  http_method = aws_api_gateway_method.item_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.saveItems.invoke_arn
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [
    aws_api_gateway_integration.item_get_lambda,
    aws_api_gateway_integration.item_post_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  stage_name  = "prod"
}

resource "aws_api_gateway_authorizer" "api_gateway_authorizer" {
  name            = "customer-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = ["${aws_cognito_user_pool.pool.arn}"]
}

output "base_url" {
  value = aws_api_gateway_deployment.deploy.invoke_url
}


