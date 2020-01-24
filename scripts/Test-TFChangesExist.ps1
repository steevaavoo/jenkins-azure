# Test script that should ONLY returns true or false
#
# IMPORTANT: when using "returnStdout: true" in Jenkins, you MUST ensure ONLY your desired value is output to the
# pipeline. DO NOT use Write-Output, Write-Host etc.

# Change into TF folder location
Push-Location -Path .\terraform

# Check for planned changes in Terraform diff file
$message = "Checking for Terraform planned changes"
Write-Verbose "`nSTARTED: $message..."
if (Get-Content diff.txt | Select-String "Plan: 0 to add, 0 to change, 0 to destroy") { $false } else { $true }
Write-Verbose "FINISHED: $message."

# Revert to previous folder location
Pop-Location
