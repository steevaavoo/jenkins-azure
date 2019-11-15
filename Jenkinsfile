pipeline {

  parameters {
    booleanParam name: 'terraform_delete', defaultValue: false, description: 'Run Terraform Delete (true), or skip (false).'
  }

  agent any

  environment {
    AKS_CLUSTER_NAME = 'stvaks1'
    AKS_RG_NAME = 'aks-rg'
    CLIENTID = 'http://tfm-k8s-spn'
    DNS_DOMAIN_NAME = 'bakers-foundry.co.uk'
    DNS_IP_ADDRESS = 'AssignedBy_Wait-LoadbalancerIP.ps1'
    LOCATION = 'eastus'
    TERRAFORM_STORAGE_ACCOUNT = 'terraformstoragestvfff79'
    TERRAFORM_STORAGE_RG = 'terraform-rg'
  }

  post {
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: "**/diff.txt"
    }
    // success {
    // }
    // failure {
    // }
    // aborted {
    // }
  }

  stages {
    stage('Init') {
      steps {
        withCredentials([azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure-jenkins', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')]) {
          pwsh(script: './scripts/Create-AzStorage.ps1')
          pwsh(script: './scripts/Get-StorageKey.ps1 ; ./scripts/Replace-Tokens.ps1')
          // pwsh(script: './scripts/Replace-Tokens.ps1')
          pwsh(script: './scripts/Init-Terraform.ps1')
        }
      }
    }

    stage('Build') {
      when {not { expression { params.terraform_delete} }}
      steps {
        withCredentials([azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure-jenkins', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')]) {
          pwsh(script: './scripts/Plan-Terraform.ps1')
          input 'Continue Terraform Apply?'
          pwsh(script: './scripts/Apply-Terraform.ps1')
        }
      }
    }

    stage('Destroy') {
      when { expression { params.terraform_delete} }
      steps {
        withCredentials([azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure-jenkins', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')]) {
          pwsh(script: './scripts/Destroy-Terraform.ps1')
        }
      }
    }
  }
}
