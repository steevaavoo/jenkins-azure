# Terraform tasks
terraform version

# Change into TF folder location
Push-Location -Path .\terraform

# Download required TF resources
$message = "Initialising Terraform environment"
Write-Output "STARTED: $message..."
terraform init
Write-Output "FINISHED: $message."

# Revert to previous folder location
Pop-Location
