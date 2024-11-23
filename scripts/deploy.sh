#!/bin/zsh
set -e

# Log file for debugging
LOG_FILE="deploy.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to deploy a Terraform configuration in a given directory
deploy() {
  local dir="$1"
  local dry_run="$2"

  echo "==== Starting deployment in directory: $dir ===="

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

  # Handle dry-run mode
  if [[ "$dry_run" == "true" ]]; then
    echo "Planning Terraform changes in $dir (dry-run mode)..."
    terraform plan || { echo "Plan failed in $dir. Exiting."; exit 1; }
  else
    # Apply the Terraform configuration
    echo "Applying Terraform configuration in $dir..."
    terraform apply -auto-approve || { echo "Apply failed in $dir. Exiting."; exit 1; }
  fi

  echo "==== Deployment complete in directory: $dir ===="
  cd - >/dev/null
}

# Main deployment process
echo "==== Starting full deployment of AWS Data Pipeline MVP ===="

# Parse input arguments
DRY_RUN="false"
DIRECTORY=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN="true"; shift ;;
    --dir) DIRECTORY="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# If a directory is specified, deploy only that directory
if [[ -n "$DIRECTORY" ]]; then
  deploy "$DIRECTORY" "$DRY_RUN"
else
  # Deploy backend-setup
  deploy "backend-setup" "$DRY_RUN"

  # Deploy main
  deploy "main" "$DRY_RUN"
fi

echo "==== Deployment of AWS Data Pipeline MVP completed successfully. ===="
