pipeline {
  agent any

  environment {
    //STORAGE_KEY = 'willbefetchedbyscript'
    AKS_CLUSTER_NAME = 'stvaks1'
    AKS_RG_NAME = 'aks-rg'
    CLIENTID = 'http://tfm-k8s-spn'
    DNS_DOMAIN_NAME = 'bakers-foundry.co.uk'
    DNS_IP_ADDRESS = 'AssignedBy_Wait-LoadbalancerIP.ps1'
    LOCATION = 'eastus'
    TERRAFORM_STORAGE_ACCOUNT = 'terraformstoragestvfff79'
    TERRAFORM_STORAGE_RG = 'terraform-rg'
  }

  stages {
    stage('Build') {
      steps {
        withCredentials([string(credentialsId: 'storage_key', variable: 'STORAGE_KEY'), azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure-jenkins', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')]) {
          pwsh(script: './scripts/Build-Environment.ps1')
          pwsh(script: './scripts/Prepare-Terraform.ps1')
          pwsh(script: './scripts/Invoke-Terraform.ps1')
        }
      }
    }
  }
}
