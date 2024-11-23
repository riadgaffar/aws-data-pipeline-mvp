# Project Description

This is a simple AWS Data Pipeline MVP designed to orchestrate the creation of cloud infrastructure for managing and processing data efficiently. It is built with Terraform and focuses on deploying ephemeral and reusable cloud resources using a modular architecture.

## Key Features

	•	Infrastructure as Code (IaC): Automates the provisioning of resources using Terraform for repeatable and reliable deployments.
	•	Ephemeral Stack: Supports easy deployment and teardown for testing or temporary usage.
	•	AWS Managed Services:
	  -	Amazon EKS: Kubernetes cluster for running containerized workloads.
	  -	Amazon MSK: Managed Kafka for data streaming.
	  -	Amazon S3: Data lake for scalable storage.
	  -	DynamoDB: State locking for Terraform backend.


## File structure

```zsh
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

### Deploy Full Stack (Default):

```zsh
./scripts/deploy.sh
```

### Deploy Only backend-setup Directory:

```zsh
./scripts/deploy.sh --dir backend-setup
```

### Dry Run for Full Stack:

```zsh
./scripts/deploy.sh --dry-run
```

### Dry Run for Specific Directory:

```zsh
./scripts/deploy.sh --dry-run --dir main
```

# Destroy stack

### Destroy Full Stack (Default):

```zsh
./scripts/destroy.sh
```

### Destroy Only backend-setup Directory:

```zsh
./scripts/destroy.sh --dir backend-setup
```

### Destroy Only main Directory:

```zsh
./scripts/destroy.sh --dir main
```

# Sample Outputs

	•	EKS Cluster Endpoint: Kubernetes API for managing workloads.
	•	Kafka Brokers: Endpoints for streaming data.
	•	S3 Bucket: Data lake for scalable storage.
	•	Networking: Subnet IDs, CIDR blocks, and VPC ID.

# Troubleshooting

### List Node Groups for the Cluster

```zsh
aws eks list-nodegroups --cluster-name mvp-eks-cluster
```

### If the Node Group exists, describe its details:

```zsh
aws eks describe-nodegroup --cluster-name mvp-eks-cluster --nodegroup-name default
```

### Show Terraform State for the Node Group

```zsh
terraform state show module.eks.aws_eks_node_group.this
```

### Use the following AWS CLI command to describe the Node Groups and inspect their status

**Look for the status and health fields in the response. For example:**

```zsh
aws eks describe-nodegroup --cluster-name mvp-eks-cluster --nodegroup-name default-20241123033151055300000012
aws eks describe-nodegroup --cluster-name mvp-eks-cluster --nodegroup-name default-20241123042207995800000002
```

### Investigate Instances in the Node Group

```zsh
aws ec2 describe-instances --instance-ids i-040f6dd3697221480
```
