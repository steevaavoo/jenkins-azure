# Pester integration tests for provisioned infrastructure
# Assumes az cli has already been logged in

# Pester tests
Describe "Integration Tests" {
    Context 'When Terraform config has been applied' {

        It "Resource Group [$env:AKS_RG_NAME] should exist" {
            az group exists --name $env:AKS_RG_NAME | Should be "true"
        }

        # Trigger failed tests
        if ($env:FORCE_TEST_FAIL -eq "true") {
            It "FORCE_TEST_FAIL used on Resource Group [$env:AKS_RG_NAME]" {
                "false" | Should be "true"
            }
        }
    }
}
