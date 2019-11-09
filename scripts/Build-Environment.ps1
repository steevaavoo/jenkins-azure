# Outputting environment variables
#ls env:

# This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state
#
# When using Windows agent in Azure DevOps, use batch scripting.
# For batch files use the prefix "call" before every azure command.

# Resource Group
Write-Output "STARTED: Creating Resource Group..."
az group create --location $env:LOCATION --name $env:TERRAFORM_STORAGE_RG
Write-Output "FINISHED: Creating Resource Group."

# Storage Account
Write-Output "STARTED: Creating Storage Account..."
az storage account create --name $env:TERRAFORM_STORAGE_ACCOUNT --resource-group $env:TERRAFORM_STORAGE_RG --location $env:LOCATION --sku Standard_LRS
Write-Output "FINISHED: Creating Storage Account."

# Storage Container
Write-Output "STARTED: Creating Storage Container..."
az storage container create --name "terraform" --account-name $env:TERRAFORM_STORAGE_ACCOUNT
Write-Output "FINISHED: Creating Storage Container."

# Get latest supported AKS version and update Azure DevOps Pipeline variable
Write-Output "STARTED: Finding latest supported AKS version..."
$latest_aks_version = $(az aks get-versions -l $env:LOCATION --query "orchestrators[-1].orchestratorVersion" -o tsv)
Write-Output "Updating Pipeline variable with Latest AKS Version:"
Write-Output $latest_aks_version
Write-Output "FINISHED: Finding latest supported AKS version."
