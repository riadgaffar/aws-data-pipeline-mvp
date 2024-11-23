output "backend_bucket" {
  description = "S3 bucket for Terraform state storage (alias: state_bucket_name)"
  value       = aws_s3_bucket.state_storage.id
}

output "backend_dynamodb_table" {
  description = "DynamoDB table for state locking (alias: state_lock_table_name)"
  value       = aws_dynamodb_table.state_locks.name
}
