Get-AzResourceGroup | Remove-AzResourceGroup -AsJob -Force
Get-Job | Wait-Job