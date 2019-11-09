pipeline {
  agent any

  environment {
    RG_NAME = 'test-rg'
    LOCATION = 'eastus'
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