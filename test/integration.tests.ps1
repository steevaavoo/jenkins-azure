# Pester integration tests for provisioned infrastructure
# Assumes az cli has already been logged in

# Pester tests
Describe "Integration Tests" {

    # Terraform State Storage
    Context 'When Terraform has provisioned: [TERRAFORM STATE STORAGE]' {

        # [CI Param Option] Trigger failed test on purpose
        if ($env:FORCE_TEST_FAIL -eq "true") {
            It "FORCE_TEST_FAIL used on Resource Group [$env:AKS_RG_NAME]" {
                "false" | Should be "true"
            }
        }

        It "Resource Group [$env:TERRAFORM_STORAGE_RG] should exist" {
            az group exists --name $env:TERRAFORM_STORAGE_RG | Should be "true"
        }

        It "Storage Account [$env:TERRAFORM_STORAGE_ACCOUNT] should exist" {
            az storage account show --name $env:TERRAFORM_STORAGE_ACCOUNT --query "provisioningState" -o tsv | Should be "Succeeded"
        }

        It "Storage Blob [terraform.tfstate] in Container [terraform] should exist" {
            az storage blob exists --account-name $env:TERRAFORM_STORAGE_ACCOUNT --container-name "terraform" --name "terraform.tfstate" --query "exists" -o tsv | Should be "true"
        }
    }

    # Azure Container Registry
    Context 'When Terraform has provisioned: [AZURE CONTAINER REGISTRY]' {

        It "Resource Group [$env:AKS_RG_NAME] should exist" {
            az group exists --name $env:AKS_RG_NAME | Should be "true"
        }

        It "Azure Container Registry [$env:ACR_NAME] should exist" {
            az group show --name $env:ACR_NAME --resource-group $env:AKS_RG_NAME --query "properties.provisioningState" -o tsv | Should be "Succeeded"
        }

        It "Container Repository [$env:CONTAINER_IMAGE_NAME] should exist" {
            az acr repository show --name $env:ACR_NAME --image $env:CONTAINER_IMAGE_TAG_FULL --query "name" -o tsv | Should be $env:CONTAINER_IMAGE_TAG
        }
    }

    # Azure Kubernetes Service
    Context 'When Terraform has provisioned: [AZURE KUBERNETES SERVICE]' {

        It "Resource Group [$env:AKS_RG_NAME] should exist" {
            az group exists --name $env:AKS_RG_NAME | Should be "true"
        }

        It "Azure Kubernetes Service [$env:AKS_CLUSTER_NAME] should exist" {
            az aks show --name $env:AKS_CLUSTER_NAME --resource-group $env:AKS_RG_NAME --query "provisioningState" -o tsv | Should be "Succeeded"
        }
    }

    # DNS record updated
    Context "When DNS record has been updated for: [$env:DNS_DOMAIN_NAME]" {

        # Vars
        $testUrl = "https://$($env:DNS_DOMAIN_NAME)"
        $testUrlNodeApp = "$($testUrl)/helloworld"
        $allowedStatusCodes = @(200, 304, 404, 503)
        $expectedContent = "Hello world"

        It "A request to [$testUrl] should return an allowed Status Code: [$($allowedStatusCodes -join ', ')]" {
            $responseStatusCode = curl -s -o /dev/null -w "%{http_code}" $testUrl
            $responseStatusCode | Should BeIn $allowedStatusCodes
        }

        It "A request to [$testUrlNodeApp] should include [$expectedContent] in the returned content" {
            curl $testUrlNodeApp | Should be $expectedContent
        }
    }
}
