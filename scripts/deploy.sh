#!/bin/zsh
set -e

deploy() {
  local dir="$1"

  echo "Starting deployment in directory: $dir"

  # Navigate to the directory
  cd "$dir"

  # Check if Terraform is initialized
  if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform in $dir..."
    terraform init -input=false
  else
    echo "Terraform already initialized in $dir."
  fi

  # Validate the Terraform configuration
  echo "Validating Terraform configuration in $dir..."
  terraform validate

  # Apply the Terraform configuration
  echo "Applying Terraform configuration in $dir..."
  terraform apply -auto-approve

  echo "Deployment complete in directory: $dir"
  cd - >/dev/null
}

echo "Starting full deployment of AWS Data Pipeline MVP..."

# Deploy backend-setup
deploy "backend-setup"

# Deploy main
deploy "main"

echo "Deployment of AWS Data Pipeline MVP completed successfully."
