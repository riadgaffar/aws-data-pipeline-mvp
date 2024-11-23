#!/bin/zsh
set -e

destroy() {
  echo "Destroying Terraform resources in $(pwd)..."
  
  # Ensure Terraform is initialized
  if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform in $(pwd)..."
    terraform init -input=false
  fi
  
  # Destroy the Terraform stack
  terraform destroy -auto-approve

  echo "Cleaning up Terraform files in $(pwd)..."
  rm -rf tfplan .terraform .terraform.lock.hcl terraform.tfstate *.backup
}

echo "Starting teardown of AWS Data Pipeline MVP..."

# Navigate to the backend-setup directory
cd backend-setup
echo "Entering backend-setup directory..."
destroy

# Navigate to the main directory
cd ../main
echo "Entering main directory..."
destroy

echo "Teardown complete."
