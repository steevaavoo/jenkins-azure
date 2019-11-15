# Terraform tasks
terraform version

# Change into TF folder location
Push-Location -Path .\terraform

# Download required TF resources
terraform init

# Calculate planned changes
terraform plan

# Apply terraform
terraform apply -auto-approve

# Revert to previous folder location
Pop-Location
