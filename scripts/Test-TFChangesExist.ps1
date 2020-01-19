# Change into TF folder location
Push-Location -Path .\terraform

# Check for planned changes in Terraform diff file
if (Get-Content diff.txt | Select-String "Plan: 0 to add, 0 to change, 0 to destroy") { $false } else { $true }

# Revert to previous folder location
Pop-Location
