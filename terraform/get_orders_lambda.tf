
data "archive_file" "lambda_zip_getOrders" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_getOrders.zip"
  source {
    content  = file("functions/getOrders/index.js")
    filename = "index.js"
  }
}

resource "aws_lambda_function" "getOrders" {
  function_name = "GetOrdersTerraform"

  filename         = data.archive_file.lambda_zip_getOrders.output_path
  source_code_hash = data.archive_file.lambda_zip_getOrders.output_base64sha256

  # # The bucket name as created earlier with "aws s3api create-bucket"
  # s3_bucket = "terraform-serverless-example17121996"
  # s3_key    = "v1.0.0/getOrders.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.get_order_lambda_exec.arn
}

resource "aws_iam_role_policy_attachment" "get_itemorder_policy" {
  role       = aws_iam_role.get_order_lambda_exec.name
  policy_arn = aws_iam_policy.get_items_table_access_order.arn
}

resource "aws_iam_role_policy_attachment" "get_order_policy" {
  role       = aws_iam_role.get_order_lambda_exec.name
  policy_arn = aws_iam_policy.get_orders_table_access.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "get_order_lambda_exec" {
  name = "getOrders_lambda"

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

# access dynamobd.
resource "aws_iam_policy" "get_items_table_access_order" {
  name        = "get_items_table_access_order"
  path        = "/"
  description = "IAM policy for accessing dynamodb"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:020241801910:table/ItemsTableTerraform"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "get_orders_table_access" {
  name        = "get_orders_table_access"
  path        = "/"
  description = "IAM policy for accessing dynamodb"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:020241801910:table/OrderTableTerraform"
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "get_order_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getOrders.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.e_commerce_api_terraform.execution_arn}/*/*"
}

