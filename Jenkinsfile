pipeline {
  agent any

  environment {
    rg_name = 'test-rg'
    location = 'eastus'
  }

  stages {
    stage('Build') {
      withCredentials([azureServicePrincipal('azure-jenkins')]) {
        steps {
          pwsh(script: './scripts/Build-Environment.ps1')
        }
      }
    }
  }
}