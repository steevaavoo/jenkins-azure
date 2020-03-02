# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

$message = "Getting Storage Account Key"
Write-Output "STARTED: $message..."
$storage_key = (az storage account keys list --resource-group $env:TERRAFORM_STORAGE_RG --account-name $env:TERRAFORM_STORAGE_ACCOUNT --query [0].value -o tsv)
Write-Output "FINISHED: $message."

# Write-Verbose "Storage Key is: [$storage_key]"

$env:STORAGE_KEY = $storage_key
