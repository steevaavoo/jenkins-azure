pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        pwsh(script: './scripts/Build-Environment.ps1', returnStdout: true, returnStatus: true)
      }
    }

  }
  environment {
    rg_name = 'test-rg'
  }
}