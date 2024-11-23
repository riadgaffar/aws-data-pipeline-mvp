# Project Description

This is a simple AWS Data Pipeline MVP designed to orchestrate the creation of cloud infrastructure for managing and processing data efficiently. It is built with Terraform and focuses on deploying ephemeral and reusable cloud resources using a modular architecture.


## File structure

```bash
aws-data-pipeline-mvp/
├── backend-setup/             # Directory for backend resources setup
│   ├── main.tf                # Terraform config to create S3 bucket and DynamoDB table
│   ├── outputs.tf             # Outputs for backend resources
│   ├── variables.tf           # Variables for reusability
│   └── terraform.tfstate      # (Optional) Local state for backend setup
├── main/                      # Main project configuration
│   ├── main.tf                # Main Terraform config (uses the backend)
│   ├── outputs.tf             # Outputs for pipeline resources
│   ├── variables.tf           # Variables for pipeline configuration
│   └── terraform.tfstate      # (Optional) Local state for main deployment
├── scripts/                   # Deployment and tear down scripts
│   ├── deploy.sh              # Deploy the data pipeline stack
│   ├── destroy.sh             # Destroy the data pipeline stack
```


# Deploy Stack:

```bash
./scripts/deploy.sh
Starting full deployment of AWS Data Pipeline MVP...
.
.
.
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

backend_bucket = "mvp-state-bucket"
backend_dynamodb_table = "mvp-state-lock-table"
.
.
.
Apply complete! Resources: 50 added, 0 changed, 0 destroyed.

Outputs:

eks_cluster_endpoint = "https://7F88B317F7275D0FB3A3A9BB41EFED0B.gr7.us-east-1.eks.amazonaws.com"
kafka_cluster_brokers = "b-1.mvpkafkacluster.pi2k02.c22.kafka.us-east-1.amazonaws.com:9094,b-2.mvpkafkacluster.pi2k02.c22.kafka.us-east-1.amazonaws.com:9094"
s3_bucket_name = "mvp-data-lake-bucket"
security_group_id = "sg-0531926b6955907db"
subnet_cidr_blocks = [
  "10.0.1.0/24",
  "10.0.2.0/24",
]
subnet_ids = [
  "subnet-0baf5dc4dcc60b9ab",
  "subnet-0816d9def23ff23a3",
]
vpc_id = "vpc-0cba48a69c6be50ef"
.
.
.
Deployment of AWS Data Pipeline MVP completed successfully.
```

# Destroy stack

```bash
./scripts/deploy.sh
Starting teardown of AWS Data Pipeline MVP...
.
.
.
Teardown complete.
```

# Troubleshooting

### List Node Groups for the Cluster

```bash
aws eks list-nodegroups --cluster-name mvp-eks-cluster
```

### If the Node Group exists, describe its details:

```bash
aws eks describe-nodegroup --cluster-name mvp-eks-cluster --nodegroup-name default
```

### Show Terraform State for the Node Group

```bash
terraform state show module.eks.aws_eks_node_group.this
```

### Use the following AWS CLI command to describe the Node Groups and inspect their status

**Look for the status and health fields in the response. For example:**

```bash
aws eks describe-nodegroup --cluster-name mvp-eks-cluster --nodegroup-name default-20241123033151055300000012
aws eks describe-nodegroup --cluster-name mvp-eks-cluster --nodegroup-name default-20241123042207995800000002
```

### Investigate Instances in the Node Group

```bash
aws ec2 describe-instances --instance-ids i-040f6dd3697221480
```
