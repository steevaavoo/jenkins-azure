pipeline {
  agent any

  environment {
    rg_name = 'test-rg'
  }

  stages {
    stage('Build') {

      steps {
        azureCLI commands: [[exportVariablesString: '', script: 'az account list'], [exportVariablesString: '', script: 'az resource list']], principalCredentialId: 'azure-jenkins'
        pwsh(script: './scripts/Build-Environment.ps1', returnStdout: true, returnStatus: true)
      }

    }

  }
}