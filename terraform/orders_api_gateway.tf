
resource "aws_api_gateway_resource" "orders_proxy" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  parent_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_method" "order_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id   = aws_api_gateway_resource.orders_proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "order_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id   = aws_api_gateway_resource.orders_proxy.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_gateway_authorizer.id
}

resource "aws_api_gateway_integration" "order_get_lambda" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id = aws_api_gateway_method.order_get_method.resource_id
  http_method = aws_api_gateway_method.order_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getOrders.invoke_arn
}

resource "aws_api_gateway_integration" "order_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  resource_id = aws_api_gateway_method.order_post_method.resource_id
  http_method = aws_api_gateway_method.order_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.saveOrders.invoke_arn
}

resource "aws_api_gateway_deployment" "order_deploy" {
  depends_on = [
    aws_api_gateway_integration.order_get_lambda,
    aws_api_gateway_integration.order_post_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.e_commerce_api_terraform.id
  stage_name  = "prod"
}



