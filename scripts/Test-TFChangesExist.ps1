# Change into TF folder location
Push-Location -Path .\terraform

# Check for planned changes in Terraform diff file
$message = "Checking for Terraform planned changes"
Write-Output "`nSTARTED: $message..."
if (Get-Content diff.txt | Select-String "Plan: 0 to add, 0 to change, 0 to destroy") { $false } else { $true }
Write-Output "FINISHED: $message."

# Revert to previous folder location
Pop-Location
