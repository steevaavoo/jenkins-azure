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
    TERRAFORM_STORAGE_ACCOUNT = 'terraformstoragestv09f79'
    TERRAFORM_STORAGE_RG = 'terraform-rg'
  }

  stages {
    stage('Build') {
      steps {
        withCredentials([string(credentialsId: 'storage_key', variable: 'STORAGE_KEY'), azureServicePrincipal('azure-jenkins')]) {
          pwsh(script: './scripts/Build-Environment.ps1')
          pwsh(script: './scripts/Prepare-Terraform.ps1')
        }
      }
    }
  }
}