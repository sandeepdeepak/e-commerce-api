# ----------------------------------------------------------------------
# AWS Provider
# ----------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------------------
# Terraform S3 backend with DynamoDB Lock table
# ----------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "us-east-1-e-commerce-api-s3"
    key            = "e-commerce-api.tfstate"
    dynamodb_table = "my-terraform-lock"
    region         = "us-east-1"
    encrypt        = "true"
  }
}
