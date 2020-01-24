pipeline {

  // triggers { pollSCM('* * * * *') } // Poll every minute

  parameters {
    booleanParam name: 'terraform_delete', defaultValue: false, description: 'Run Terraform Delete (true), or skip (false).'
    booleanParam name: 'storage_delete', defaultValue: false, description: 'Also Destroy Storage (true), or skip (false).'
  }

  // Variable for Container Ingress IP
  // def ingress_ip = 'ToBeUpdated'

  agent {
      docker {
          image 'adamrushuk/psjenkinsagent:latest'
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
    DNS_DOMAIN_NAME = 'thehypepipe.co.uk'
    LOCATION = 'eastus'
    TERRAFORM_STORAGE_ACCOUNT = 'terraformstoragestvfff79'
    TERRAFORM_STORAGE_RG = 'terraform-rg'
  }

  options {
    withCredentials([
      azureServicePrincipal(credentialsId: 'azure-jenkins', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID'),
      string(credentialsId: 'API_KEY', variable: 'API_KEY'),
      string(credentialsId: 'API_SECRET', variable: 'API_SECRET')
    ])
    ansiColor('xterm')
    timestamps()
  }

  stages {
    stage('Init') {
      steps {
        pwsh(script: './scripts/Test-Docker.ps1')
        pwsh(script: './scripts/Create-AzStorage.ps1')
        // To share env vars between external scripts, you can call multiple scripts in a single line
        pwsh(script: './scripts/Get-StorageKey.ps1 ; ./scripts/Replace-Tokens.ps1')
        // pwsh(script: './scripts/Replace-Tokens.ps1')
        pwsh(script: './scripts/Init-Terraform.ps1')
      }
    }

    stage('Build') {
      when {not { expression { params.terraform_delete} }}
      options {
        timeout(time: 1, unit: 'HOURS')
      }
      steps {
        pwsh(script: './scripts/Plan-Terraform.ps1')
        script {
          // Example of a PowerShell script returning a boolean ($true or $false) to an Jenkins env var
          echo "running Test-TFChangesExist.ps1"
          env.TF_CHANGES_EXIST=pwsh(script: './scripts/Test-TFChangesExist.ps1', returnStdout: true).trim()
          echo "TF_CHANGES_EXIST is: ${TF_CHANGES_EXIST}"


          // Evaluate the env var within Jenkins process, or within an external script
          // Jenkins: env.TF_CHANGES_EXIST
          // PowerShell: $env:TF_CHANGES_EXIST
          // bash: $TF_CHANGES_EXIST
          if (env.TF_CHANGES_EXIST == "True") {
            input 'Changes found in TF plan. Continue Terraform Apply?'
            pwsh(script: './scripts/Apply-Terraform.ps1')
          } else {
            echo "SKIPPING: Terraform apply - no changes"
          }
        }
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
        pwsh(script: "./scripts/Update-Dns.ps1 -AksResourceGroupName ${AKS_RG_NAME} -AksClusterName ${AKS_CLUSTER_NAME} -DomainName ${DNS_DOMAIN_NAME} -ApiKey ${API_KEY} -ApiSecret ${API_SECRET}")
      }
    }

    stage('TerraformDestroy') {
      when { expression { params.terraform_delete} }
      options { retry(3) }
      steps {
        pwsh(script: './scripts/Destroy-Terraform.ps1')
      }
    }

    stage('StorageDestroy') {
      when { expression { params.storage_delete} }
      options { retry(3) }
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
