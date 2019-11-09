pipeline {
  agent any

  environment {
    rg_name = 'test-rg'
    location = 'eastus'
  }

  stages {
    stage('Build') {
      steps {
        withCredentials([azureServicePrincipal('azure-jenkins')]) {
          pwsh(script: './scripts/Build-Environment.ps1')
        }
      }
    }
  }
}