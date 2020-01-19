$storage_key = (az storage account keys list --resource-group $env:TERRAFORM_STORAGE_RG --account-name $env:TERRAFORM_STORAGE_ACCOUNT --query [0].value -o tsv)

Write-Output "Storage Key is: [$storage_key]"

$env:STORAGE_KEY = $storage_key
