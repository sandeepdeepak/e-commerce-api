resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "ItemsTableTerraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ItemId"
  range_key      = "UserId"

  attribute {
    name = "ItemId"
    type = "S"
  }

  attribute {
    name = "UserId"
    type = "S"
  }

}

resource "aws_dynamodb_table" "order-dynamodb-table" {
  name           = "OrderTableTerraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "OrderId"

  attribute {
    name = "OrderId"
    type = "S"
  }

}

