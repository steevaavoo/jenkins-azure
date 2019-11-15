# Change into TF folder location
Push-Location -Path .\terraform

# Apply terraform
terraform destroy -auto-approve

# Revert to previous folder location
Pop-Location
