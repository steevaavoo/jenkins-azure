pipeline {
  agent any

  environment {
    RG_NAME = 'test-rg'
    LOCATION = 'eastus'
    TERRAFORM_STORAGE_ACCOUNT = 'terraformstoragestv09f79'
    TF_CONTAINER_NAME = 'terraform'
    AKS_CLUSTER_NAME = 'stvaks1'
    AKS_RG_NAME = 'stvRG1'
    STORAGE_KEY = 'willbefetchedbyscript'
    TF_KEY = 'terraform.tfstate'
    TF_CONTAINER_NAME = 'terraform'
    DNS_DOMAIN_NAME = 'bakers-foundry.co.uk'
    DNS_IP_ADDRESS = 'AssignedBy_Wait-LoadbalancerIP.ps1'
  }

  stages {
    stage('Build') {
      steps {
        withCredentials([azureServicePrincipal('azure-jenkins')]) {
          pwsh(script: './scripts/Build-Environment.ps1')
          pwsh(script: './scripts/Multi.ps1')
        }
      }
    }
  }
}