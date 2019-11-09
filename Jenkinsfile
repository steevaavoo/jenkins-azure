pipeline {
  agent any

  environment {
    rg_name = 'test-rg'
    location = 'eastus'
  }

  stages {
    withCredentials([azureServicePrincipal('azure-jenkins')]) {
      stage('Build') {
        steps {
            pwsh(script: './scripts/Build-Environment.ps1')
        }
      }
    }
  }
}