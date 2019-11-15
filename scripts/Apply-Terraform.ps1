# Change into TF folder location
Push-Location -Path .\terraform

# Apply terraform
terraform apply -auto-approve

# Revert to previous folder location
Pop-Location
