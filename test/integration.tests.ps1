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
        $allowedStatusCodes = @(200, 304)
        $expectedContent = "Hello world"

        # Root domain
        It "A request to [$testUrl] should return an allowed Status Code: [$($allowedStatusCodes -join ', ')]" {
            $responseStatusCode = curl -k -s -o /dev/null -w "%{http_code}" $testUrl
            $responseStatusCode | Should BeIn $allowedStatusCodes
        }

        # nodeapp
        It "A request to [$testUrlNodeApp] should return an allowed Status Code: [$($allowedStatusCodes -join ', ')]" {
            $responseStatusCode = curl -k -s -o /dev/null -w "%{http_code}" $testUrl
            $responseStatusCode | Should BeIn $allowedStatusCodes
        }

        It "A request to [$testUrlNodeApp] should include [$expectedContent] in the returned content" {
            curl -k -s $testUrlNodeApp | Should be $expectedContent
        }
    }


    # SSL Certificate has been issued
    Context "When an SSL Certificate has been issued for: [$env:DNS_DOMAIN_NAME]" {

        # Vars
        $hostname = $env:DNS_DOMAIN_NAME
        $port = 443
        # Number of days out to warn about certificate expiration
        $warningThreshold = 14

        switch ($env:CERT_API_ENVIRONMENT) {
            prod { $expectedIssuerName = "Let's Encrypt Authority" }
            staging { $expectedIssuerName = "Fake LE Intermediate" }
            Default { $expectedIssuerName = "NOT DEFINED" }
        }

        # Get common cert info
        . ../scripts/Get-CertInfo.ps1
        $certResult = Get-CertInfo -ComputerName $hostname -Port $port

        # DEBUG Output
        if ($env:CI_DEBUG -eq "true") { $certResult | Out-String | Write-Verbose }

        # Tests
        It "Should have a [$env:CERT_API_ENVIRONMENT] SSL cert for [$hostname] issued by: [$expectedIssuerName]" {
            $certResult.Issuer -match $expectedIssuerName | Should Be $true
        }

        # Do extra supported tests if on Windows OS
        if ($IsWindows) {
            # Get cert
            . ../scripts/Test-SslProtocol.ps1
            $sslResult = Test-SslProtocol -ComputerName $hostname -Port $port

            # DEBUG Output
            if ($env:CI_DEBUG -eq "true") { $sslResult | Out-String | Write-Verbose }

            It "Should have Signature Algorithm of [sha256RSA]" {
                $sslResult.SignatureAlgorithm | Should Be "sha256RSA"
            }

            It "Should support TLS1.2" {
                $sslResult.TLS12 | Should Be $True
            }

            It "Should not expire within [$warningThreshold] days" {
                ($sslResult.Certificate.NotAfter -gt (Get-Date).AddDays($warningThreshold)) | Should Be $True
            }
        }
    }
}
