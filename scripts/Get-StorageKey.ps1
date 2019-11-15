$env:STORAGE_KEY = (Get-AzStorageAccountKey -ResourceGroupName $env:TERRAFORM_STORAGE_RG -AccountName $env:TERRAFORM_STORAGE_ACCOUNT).Value[0]
