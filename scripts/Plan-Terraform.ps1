# Change into TF folder location
Push-Location -Path .\terraform

# Plan with differential output
terraform plan -out=tfplan
Write-Output "Terraform Plan - Generated on: $(date)\n" > diff.txt
terraform show -no-color tfplan | Tee-Object -FilePath diff.txt

# Revert to previous folder location
Pop-Location
