# Checks for planned changes in Terraform config
# This script should ONLY return true or false to StdOut
#
# IMPORTANT: when using "returnStdout: true" in Jenkins, you must ensure ONLY your desired value is output to the
# pipeline. DO NOT use Write-Output, Write-Host, or output anything else into the pipeline.
#
# If you are using the returnStdout option of the powershell Pipeline step then only stream 1 will be returned,
# while streams 2-6 will be redirected to the console output if you enable stream pref to "Continue"
# eg: $VerbosePreference = "Continue"
# Ref: https://jenkins.io/blog/2017/07/26/powershell-pipeline/

# Set prefs
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Change into TF folder location
Push-Location -Path .\terraform

# Check for planned changes in Terraform diff file
$message = "Checking for Terraform planned changes"
Write-Verbose "STARTED: $message..."
if (Get-Content diff.txt | Select-String "Plan: 0 to add, 0 to change, 0 to destroy") { $false } else { $true }
Write-Verbose "FINISHED: $message."

# Revert to previous folder location
Pop-Location
