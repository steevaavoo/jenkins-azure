# Change into TF folder location
Push-Location -Path .\terraform

# Apply terraform
$message = "Destroying Terraform configuration"
Write-Output "`nSTARTED: $message..."
terraform destroy -auto-approve
Write-Output "FINISHED: $message."

# Revert to previous folder location
Pop-Location
