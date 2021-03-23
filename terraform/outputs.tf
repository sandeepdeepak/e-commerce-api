output "base_url" {
  value = aws_api_gateway_deployment.deploy.invoke_url
}

output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

//after output is printed use this command below:
//terraform output -json | jq -r '@sh "export userPoolId=\(.user_pool_id.value)\nexport appClientId=\(.app_client_id.value)"'
