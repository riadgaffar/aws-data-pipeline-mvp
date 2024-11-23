variable "aws_region" {
  description = "AWS region for the resources"
  default     = "us-east-1"
}

variable "owner" {
  description = "Owner of the infrastructure"
  default     = "gaffarr"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for the data lake"
  default     = "mvp-state-bucket"
}
