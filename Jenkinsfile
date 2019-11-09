pipeline {
  agent any

  environment {
    rg_name = 'test-rg'
  }

  stages {
    stage('Build') {

      steps {
        pwsh(script: './scripts/Build-Environment.ps1', returnStdout: true, returnStatus: true)
      }

    }

  }
}