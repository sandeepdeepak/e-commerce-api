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

resource "aws_iam_role" "group_role" {
  name = "user-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "us-east-1:12345678-dead-beef-cafe-123456790ab"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_cognito_user_group" "admin-group-terraform" {
  name         = "admin-group-terraform"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Managed by Terraform"
  precedence   = 42
  role_arn     = aws_iam_role.group_role.arn
}

resource "aws_cognito_user_group" "customer-group-terraform" {
  name         = "customer-group-terraform"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Managed by Terraform"
  precedence   = 42
  role_arn     = aws_iam_role.group_role.arn
}

