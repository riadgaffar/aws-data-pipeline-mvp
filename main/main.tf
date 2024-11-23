provider "aws" {
  region = var.aws_region
}

# Fetch Availability Zones Dynamically
data "aws_availability_zones" "available" {}

# VPC Configuration
resource "aws_vpc" "mvp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "mvp-vpc"
    Environment = var.environment
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "mvp_igw" {
  vpc_id = aws_vpc.mvp_vpc.id

  tags = {
    Name        = "mvp-igw"
    Environment = var.environment
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "mvp_nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "mvp-nat-eip"
    Environment = var.environment
  }
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "mvp_nat_gw" {
  allocation_id = aws_eip.mvp_nat_eip.id
  subnet_id     = aws_subnet.mvp_subnet_a.id # NAT Gateway placed in Public Subnet

  tags = {
    Name        = "mvp-nat-gateway"
    Environment = var.environment
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.mvp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mvp_igw.id
  }

  tags = {
    Name        = "mvp-public-route-table"
    Environment = var.environment
  }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.mvp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mvp_nat_gw.id
  }

  tags = {
    Name        = "mvp-private-route-table"
    Environment = var.environment
  }
}

# Public Subnet A
resource "aws_subnet" "mvp_subnet_a" {
  vpc_id                  = aws_vpc.mvp_vpc.id
  cidr_block              = var.subnet_cidr_blocks[0]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "mvp-subnet-a"
    Environment = var.environment
  }
}

# Private Subnet B
resource "aws_subnet" "mvp_subnet_b" {
  vpc_id                  = aws_vpc.mvp_vpc.id
  cidr_block              = var.subnet_cidr_blocks[1]
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name        = "mvp-subnet-b"
    Environment = var.environment
  }
}

# Associate Public Subnet A with Public Route Table
resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.mvp_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnet B with Private Route Table
resource "aws_route_table_association" "private_subnet_b" {
  subnet_id      = aws_subnet.mvp_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group
resource "aws_security_group" "mvp_sg" {
  vpc_id = aws_vpc.mvp_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.trusted_cidr_blocks # Control plane access
  }

  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.trusted_cidr_blocks # Pod communication
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "mvp-security-group"
    Environment = var.environment
  }
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "node_group_role" {
  name = "${var.eks_cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Required Policies to Node Group Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Launch Template for EKS Node Group
resource "aws_launch_template" "eks_node_group_template" {
  name = "${var.eks_cluster_name}-node-group-template"

  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = "t3.micro"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = var.environment
    }
  }
}

# S3 Bucket Data lake
resource "aws_s3_bucket" "data_lake" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Data Lake"
    Environment = var.environment
  }
}

# MSK Cluster
resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = var.kafka_cluster_name
  kafka_version          = "2.8.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = [aws_subnet.mvp_subnet_a.id, aws_subnet.mvp_subnet_b.id]
    security_groups = [aws_security_group.mvp_sg.id]
  }

  tags = {
    Name        = "Kafka Cluster"
    Environment = var.environment
  }
}

# Data resource referenced in eks_ami
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${module.eks.cluster_version}/amazon-linux-2/recommended/image_id"
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.29.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_version
  subnet_ids      = [aws_subnet.mvp_subnet_a.id, aws_subnet.mvp_subnet_b.id]
  vpc_id          = aws_vpc.mvp_vpc.id

  eks_managed_node_groups = {
    default = {
      desired_size   = var.node_group_desired_size
      max_size       = var.node_group_max_size
      min_size       = var.node_group_min_size
      instance_types = var.node_group_instance_types
      iam_role_arn   = aws_iam_role.node_group_role.arn
      launch_template = {
        id      = aws_launch_template.eks_node_group_template.id
        version = "$Latest"
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
