#!/bin/zsh
set -e

# Log file for debugging
LOG_FILE="destroy.log"
exec > >(tee -a "$LOG_FILE") 2>&1

destroy() {
  local dir="$1"

  echo "==== Starting destruction in directory: $dir ===="

  # Navigate to the directory
  cd "$dir"

  # Check if Terraform is initialized
  if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform in $dir..."
    terraform init -input=false
  else
    echo "Terraform is already initialized in $dir."
  fi

  # Validate the Terraform configuration
  echo "Validating Terraform configuration in $dir..."
  terraform validate || { echo "Validation failed in $dir. Exiting."; exit 1; }

  # Plan and destroy the Terraform configuration
  echo "Planning Terraform destruction in $dir..."
  terraform plan -destroy -out=tfplan || { echo "Plan failed in $dir. Exiting."; exit 1; }

  echo "Destroying Terraform resources in $dir..."
  terraform destroy -auto-approve || { echo "Destroy failed in $dir. Exiting."; exit 1; }

  echo "Cleaning up Terraform files in $dir..."
  rm -rf tfplan .terraform .terraform.lock.hcl terraform.tfstate *.backup

  echo "==== Destruction complete in directory: $dir ===="
  cd - >/dev/null
}

# Main teardown process
echo "==== Starting teardown of AWS Data Pipeline MVP ===="

# Parse input arguments
DIRECTORY=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dir) DIRECTORY="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# If a directory is specified, destroy only that directory
if [[ -n "$DIRECTORY" ]]; then
  destroy "$DIRECTORY"
else
  # Destroy backend-setup
  destroy "backend-setup"

  # Destroy main
  destroy "main"
fi

echo "==== Teardown of AWS Data Pipeline MVP completed successfully. ===="
