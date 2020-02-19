pipeline {

  // triggers { pollSCM('* * * * *') } // Poll every minute

  parameters {
    booleanParam name: 'STORAGE_DELETE', defaultValue: false, description: 'Also Destroy Storage (true), or skip (false).'
    booleanParam name: 'TERRAFORM_DELETE', defaultValue: false, description: 'Run Terraform Delete (true), or skip (false).'
    booleanParam name: 'CI_DEBUG', defaultValue: false, description: 'Enables debug logs (true), or skips (false).'
    booleanParam name: 'FORCE_TEST_FAIL', defaultValue: false, description: 'Triggers failing tests (true), or normal tests (false).'
    choice       name: 'DNS_DOMAIN_NAME', choices: ['bakers-foundry.co.uk', 'thehypepipe.co.uk'], description: 'Selecting between Steve\'s Domain Name and Adam\'s Domain Name for collaborative builds.'
    choice       name: 'DOCKER_REPO',choices: ['steevaavoo', 'adamrushuk'], description: 'Selecting between Steve\'s Docker Repository and Adam\'s Docker Repository for collaborative builds.'
  }

  agent {
      docker {
          image "${DOCKER_REPO}/psjenkinsagent:latest"
          //label 'my-defined-label'
          args  '-v /var/run/docker.sock:/var/run/docker.sock'
      }
  }

  environment {
    ACR_FQDN = "${ACR_NAME}.azurecr.io"
    ACR_NAME = 'stvcontreg1'
    AKS_CLUSTER_NAME = 'stvaks1'
    AKS_IMAGE = "${ACR_FQDN}/${CONTAINER_IMAGE_TAG_FULL}"
    AKS_RG_NAME = 'aks-rg'
    CLIENTID = 'http://tfm-k8s-spn'
    CONTAINER_IMAGE_NAME = 'nodeapp'
    CONTAINER_IMAGE_TAG = 'latest'
    CONTAINER_IMAGE_TAG_FULL = "${CONTAINER_IMAGE_NAME}:${CONTAINER_IMAGE_TAG}"
    // DNS_DOMAIN_NAME = "${DNS_DOMAIN_NAME}"
    LOCATION = 'uksouth'
    //STORAGE_KEY = 'env var set by Get-StorageKey.ps1'
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
        pwsh(script: './scripts/Login-Azure.ps1')
        pwsh(script: './scripts/Test-Docker.ps1')
        pwsh(script: './scripts/Create-AzStorage.ps1')
        // To share env vars between external scripts, you can call multiple scripts in a single line
        pwsh(script: './scripts/Get-StorageKey.ps1 ; ./scripts/Replace-Tokens.ps1')
        pwsh(script: './scripts/Init-Terraform.ps1')
      }
    }

    stage('Build') {
      when {not { expression { params.TERRAFORM_DELETE} }}
      options {
        // Timeout for whole Stage
        timeout(time: 1, unit: 'HOURS')
      }
      steps {
        pwsh(script: './scripts/Plan-Terraform.ps1')
        script {
          // Example of a PowerShell script returning a boolean ($true or $false) to an Jenkins env var
          echo "running Test-TFChangesExist.ps1"
          // NOTE: Use '$VerbosePreference = "Continue"' in PowerShell script to capture Verbose stream
          // NOTE: Use '$ErrorActionPreference = "Stop"' in PowerShell script to ensure build stops on errors
          env.TF_CHANGES_EXIST=pwsh(script: './scripts/Test-TFChangesExist.ps1', returnStdout: true).trim()
          echo "TF_CHANGES_EXIST is: ${TF_CHANGES_EXIST}"

          // Evaluate the env var within Jenkins process, or within an external script
          // Jenkins: env.TF_CHANGES_EXIST
          // PowerShell: $env:TF_CHANGES_EXIST
          // bash: $TF_CHANGES_EXIST
          if (env.TF_CHANGES_EXIST == "True") {

            //   "activity" param doesn't work as expected, so not currently using
            //   Use "activity: true" to timeout after inactivity
            //   Use "activity: false" to continue after inactivity
            timeout(activity: false, time: 5) {
              // TODO: Add TF diff summmary to input prompt?
              input 'Changes found in TF plan. Continue Terraform Apply?'
            }

            pwsh(script: './scripts/Apply-Terraform.ps1')

          } else {
            echo "SKIPPING: Terraform apply - no changes"
          }
        }
      }
    }

    stage('Docker') {
      when {not { expression { params.TERRAFORM_DELETE} }}
      steps {
        pwsh(script: './scripts/Build-DockerImage.ps1')
      }
    }

    stage('Deploy-Kubernetes') {
      when {not { expression { params.TERRAFORM_DELETE} }}
      steps {
        pwsh(script: "./scripts/Deploy-Ingress-Controller.ps1")
        pwsh(script: './scripts/Deploy-Manifests.ps1')
        pwsh(script: "./scripts/Update-Dns.ps1 -AksResourceGroupName ${AKS_RG_NAME} -AksClusterName ${AKS_CLUSTER_NAME} -DomainName ${DNS_DOMAIN_NAME} -ApiKey ${API_KEY} -ApiSecret ${API_SECRET}")
      }
    }

    stage('Test') {
      when {not { expression { params.TERRAFORM_DELETE} }}
      steps {
        pwsh(script: './scripts/test.ps1')
      }
    }

    stage('Destroy-Terraform') {
      when { expression { params.TERRAFORM_DELETE} }
      options { retry(3) }
      steps {
        pwsh(script: './scripts/Destroy-Terraform.ps1')
      }
    }

    stage('Destroy-Storage') {
      when { expression { params.STORAGE_DELETE} }
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
