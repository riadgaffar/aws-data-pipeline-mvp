provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "state_storage" {
  bucket = var.bucket_name
  tags = {
    Name = "Terraform State Storage"
  }
}

resource "aws_s3_bucket_versioning" "state_storage" {
  bucket = aws_s3_bucket.state_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Logging Bucket for Data
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "mvp-logging-bucket"

  tags = {
    Name        = "Logging Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_logging" "data_lake_logging" {
  bucket        = aws_s3_bucket.state_storage.id # Reference the correct bucket
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "data-lake-logs/"
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "state_locks" {
  name         = "mvp-state-lock-table" # Replace with your table name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Locks"
    Environment = "shared" # Tag to denote this is shared infrastructure
  }
}
