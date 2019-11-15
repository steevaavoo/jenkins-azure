$storage_key = (Get-AzStorageAccountKey -ResourceGroupName $env:TERRAFORM_STORAGE_RG -AccountName $env:TERRAFORM_STORAGE_ACCOUNT).Value[0]

Write-Output "Storage Key is: [$storage_key]"

$env:STORAGE_KEY = $storage_key
