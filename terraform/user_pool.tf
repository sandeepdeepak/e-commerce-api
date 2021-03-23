resource "aws_cognito_user_pool" "pool" {
  name = "Customer Pool terraform"
  password_policy {
    minimum_length    = 6
    require_uppercase = false
  }
  lambda_config {
    pre_sign_up = aws_lambda_function.presignup.arn
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                = "client"
  user_pool_id        = aws_cognito_user_pool.pool.id
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

