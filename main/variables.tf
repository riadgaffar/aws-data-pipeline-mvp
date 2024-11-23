# General Variables
variable "aws_region" {
  description = "AWS region for the resources"
  default     = "us-east-1"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging (e.g., dev, staging, prod)"
  default     = "dev"
  type        = string
}

# VPC and Networking Variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for the subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(string)
}

variable "trusted_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress traffic"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

# S3 Variables
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for the data lake"
  type        = string
  default     = "mvp-data-lake-bucket"
}

variable "logging_bucket_name" {
  description = "Name of the S3 bucket for logging"
  type        = string
  default     = "mvp-logging-bucket"
}

# Kafka Variables
variable "kafka_cluster_name" {
  description = "Name of the Kafka cluster"
  default     = "mvp-kafka-cluster"
  type        = string
}

# EKS Variables
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "mvp-eks-cluster"
  type        = string
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  validation {
    condition     = contains(["1.25", "1.29"], var.eks_version)
    error_message = "Unsupported Kubernetes version. Allowed versions are: 1.25, 1.29."
  }
  default = "1.29"
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS Node Group"
  default     = 1
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS Node Group"
  default     = 1
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS Node Group"
  default     = 2
  type        = number
}

variable "node_group_instance_types" {
  description = "List of instance types for the EKS Node Group"
  default     = ["t3.micro"]
  type        = list(string)
}

# Additional Variables (Optional for Flexibility)
variable "eks_launch_template_name" {
  description = "Name of the launch template for the EKS Node Group"
  type        = string
  default     = "mvp-node-launch-template"
}
