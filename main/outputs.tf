# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.mvp_vpc.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = [aws_subnet.mvp_subnet_a.id, aws_subnet.mvp_subnet_b.id]
}

output "subnet_cidr_blocks" {
  description = "Subnet CIDR Blocks"
  value       = [
    aws_subnet.mvp_subnet_a.cidr_block,
    aws_subnet.mvp_subnet_b.cidr_block
  ]
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.mvp_sg.id
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Data Lake S3 Bucket Name"
  value       = aws_s3_bucket.data_lake.id
}

# Kafka Outputs
output "kafka_cluster_brokers" {
  description = "Kafka Cluster Bootstrap Brokers"
  value       = aws_msk_cluster.kafka_cluster.bootstrap_brokers_tls
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}
