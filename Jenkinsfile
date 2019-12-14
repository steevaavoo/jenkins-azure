pipeline {

  // triggers { pollSCM('* * * * *') } // Poll every minute

  parameters {
    booleanParam name: 'terraform_delete', defaultValue: false, description: 'Run Terraform Delete (true), or skip (false).'
    booleanParam name: 'storage_delete', defaultValue: false, description: 'Also Destroy Storage (true), or skip (false).'
  }

  agent {
      docker {
          image 'steevaavoo/psjenkinsagent:latest'
          //label 'my-defined-label'
          args  '-v /var/run/docker.sock:/var/run/docker.sock'
      }
  }

  environment {
    //STORAGE_KEY  = 'willbefetchedbyscript'
    AKS_CLUSTER_NAME = 'stvaks1'
    AKS_RG_NAME = 'aks-rg'
    CLIENTID = 'http://tfm-k8s-spn'
    CONTAINER_REGISTRY_NAME = 'stvcontreg1'
    CONTAINER_REGISTRY_REPOSITORY = 'samples/nodeapp'
    ACR_REPOSITORY = "${CONTAINER_REGISTRY_NAME}.azurecr.io/${CONTAINER_REGISTRY_REPOSITORY}:${CONTAINER_IMAGE_TAG}"
    CONTAINER_IMAGE_TAG = 'latest'
    DNS_DOMAIN_NAME = 'bakers-foundry.co.uk'
    DNS_IP_ADDRESS = 'AssignedBy_Wait-LoadbalancerIP.ps1'
    LOCATION = 'eastus'
    TERRAFORM_STORAGE_ACCOUNT = 'terraformstoragestvfff79'
    TERRAFORM_STORAGE_RG = 'terraform-rg'
  }

  options {
    withCredentials([azureServicePrincipal(clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', credentialsId: 'azure-jenkins', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID')])
    ansiColor('xterm')
    timestamps()
  }

  stages {
    stage('Init') {
      steps {
        pwsh(script: './scripts/Test-Docker.ps1')
        pwsh(script: './scripts/Create-AzStorage.ps1')
        pwsh(script: './scripts/Get-StorageKey.ps1 ; ./scripts/Replace-Tokens.ps1')
        // pwsh(script: './scripts/Replace-Tokens.ps1')
        pwsh(script: './scripts/Init-Terraform.ps1')
      }
    }

    stage('Build') {
      when {not { expression { params.terraform_delete} }}
      steps {
        pwsh(script: './scripts/Plan-Terraform.ps1')
        input 'Continue Terraform Apply?'
        pwsh(script: './scripts/Apply-Terraform.ps1')
      }
    }

    stage('Docker') {
      when {not { expression { params.terraform_delete} }}
      steps {
        pwsh(script: './scripts/Build-DockerImage.ps1')
        pwsh(script: './scripts/Push-DockerImage.ps1')
      }
    }

    stage('DeployK8s') {
      when {not { expression { params.terraform_delete} }}
      steps {
        pwsh(script: './scripts/Deploy-Manifests.ps1')
      }
    }

    stage('TerraformDestroy') {
      when { expression { params.terraform_delete} }
      steps {
        pwsh(script: './scripts/Destroy-Terraform.ps1')
      }
    }

    stage('StorageDestroy') {
      when { expression { params.storage_delete} }
      steps {
        pwsh(script: './scripts/Destroy-Storage.ps1')
      }
    }

  }

  post {
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: "**/diff.txt"
      archiveArtifacts allowEmptyArchive: true, artifacts: '**/*-junit.xml'
      junit allowEmptyResults: true, testResults: '**/*-junit.xml'
    }
    // success {
    // }
    // failure {
    // }
    // aborted {
    // }
  }

}