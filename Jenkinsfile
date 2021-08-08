pipeline {

  // triggers { pollSCM('* * * * *') } // Poll every minute

  parameters {
    string       name: 'PREFIX', defaultValue: 'ruba', description: 'Choose a 4 character prefix to ensure globally unique resource names', trim: true
    string       name: 'EMAIL_ADDRESS', defaultValue: 'admin@domain.com', description: 'Enter an email address used for SSL cert info', trim: true
    choice       name: 'DNS_DOMAIN_NAME', choices: ['aks.bakers-foundry.co.uk', 'aks.thehypepipe.co.uk'], description: 'Selecting between Adam\'s and Steve\'s Domain Names for collaborative builds.'
    choice       name: 'CERT_API_ENVIRONMENT', choices: ['staging', 'prod'], description: 'Select which SSL cert API environment is used.'
    booleanParam name: 'HAS_SUBDOMAIN', defaultValue: true, description: 'Tick if using a subdomain (true), or untick if just base domain name used (false).'
    choice       name: 'DOCKER_REPO',choices: ['steevaavoo', 'adamrushuk'], description: 'Selecting between Adam\'s and Steve\'s Docker Repositories for collaborative builds.'
    booleanParam name: 'CI_DEBUG', defaultValue: false, description: 'Enables debug logs (true), or skips (false).'
    booleanParam name: 'STORAGE_DELETE', defaultValue: false, description: 'Also Destroy Storage (true), or skip (false).'
    booleanParam name: 'TERRAFORM_DELETE', defaultValue: false, description: 'Run Terraform Delete (true), or skip (false).'
    booleanParam name: 'FORCE_CONTAINER_BUILD', defaultValue: false, description: 'Forces ACR container build (true) or skips (false) when tag already exists.'
    booleanParam name: 'FORCE_TEST_FAIL', defaultValue: false, description: 'Triggers failing tests (true), or normal tests (false).'
  }

  agent {
      docker {
          image "${DOCKER_REPO}/psjenkinsagent:latest"
          // label 'jenkins-agent' // use a label to target pre-configured agents
          args  '-v /var/run/docker.sock:/var/run/docker.sock'
          // above maps the socket of the Docker-in-Docker container to the local container to facilitate
          // communication with the running Docker daemon on the "host" container
      }
  }

  // Ensure Azure naming conventions are used, with globally unique names as required
  // source: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#sample-naming-convention
  environment {
    ACR_FQDN = "${ACR_NAME}.azurecr.io"
    ACR_NAME = "${PREFIX}acr001${LOCATION}001" // alpha numeric characters only
    AKS_CLUSTER_NAME = "${PREFIX}-aks-001"
    AKS_IMAGE = "${ACR_FQDN}/${CONTAINER_IMAGE_TAG_FULL}"
    AKS_RG_NAME = "${PREFIX}-rg-aks-dev-001"
    CLIENTID = 'http://tfm-k8s-spn'
    CONTAINER_IMAGE_NAME = 'nodeapp'
    CONTAINER_IMAGE_TAG = '2020-02-19'
    CONTAINER_IMAGE_TAG_FULL = "${CONTAINER_IMAGE_NAME}:${CONTAINER_IMAGE_TAG}"
    // DNS_DOMAIN_NAME = "${DNS_DOMAIN_NAME}"
    LOCATION = 'uksouth'
    //STORAGE_KEY = 'env var set by Get-StorageKey.ps1'
    TERRAFORM_STORAGE_ACCOUNT = "${PREFIX}sttfstate${LOCATION}001"
    TERRAFORM_STORAGE_RG = "${PREFIX}-rg-tfstate-dev-001"
  }

  options {
    withCredentials([
      // These variables need to be populated with info in Jenkins Credentials by creating an App Registration in Azure AD
      // choose "Accounts in this organizational directory only (Default Directory only - Single tenant)"
      // Once that's done, set up an Azure Service Principal credential in Jenkins - paste the info from the Azure
      // App Registration summary. Tenant ID is in Default Directory Overview.
      // This is similar to a service account in Active Directory to which rights, roles and permissions can be assigned.
      // It's a user account, but with no details, just an ID.
      // To allow this Service Principal to interact with the Azure Subscription, you need to add permissions in
      // Subscriptions > [your subscription] > Access Control (IAM) > Role Assignments > + Add
      // Role = Contributor, Assign access to = User, group or service principal, then select your Service Principal
      // and Save
      // azureServicePrincipal denotes the credential type to look for in Jenkins Credential store.
      // credentialsId is the name we saved it as. clientIdVariable: 'NAME' is assigning that variable a name to which
      // we will refer inside the called script
      azureServicePrincipal(credentialsId: 'azure-jenkins', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', tenantIdVariable: 'ARM_TENANT_ID'),
      // string(credentialsId: 'API_KEY', variable: 'API_KEY'),
      // string(credentialsId: 'API_SECRET', variable: 'API_SECRET')
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

    stage('Terraform') {
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

            // Get summary text
            tf_changes_summary=pwsh(script: './scripts/Get-TFPlanSummary.ps1', returnStdout: true).trim()

            //  "activity" param doesn't work as expected, so not currently using
            //  Use "activity: true" to timeout after inactivity
            //  Use "activity: false" to continue after inactivity
            timeout(activity: false, time: 5) {
              input "Terraform Summary: \n[${tf_changes_summary}]. \n\nContinue Terraform Apply?"
            }

            pwsh(script: './scripts/Apply-Terraform.ps1')

          } else {
            echo "SKIPPING: Terraform apply - no changes"
          }
        }
      }
    }

    stage('Build-Docker-Image') {
      when {not { expression { params.TERRAFORM_DELETE} }}
      steps {
        pwsh(script: './scripts/Build-DockerImage.ps1')
      }
    }

    // stage('Deploy-Kubernetes') {
    //   when {not { expression { params.TERRAFORM_DELETE} }}
    //   steps {
    //     pwsh(script: "./scripts/Deploy-Ingress-Controller.ps1")
    //     pwsh(script: "./scripts/Update-Dns.ps1 -AksResourceGroupName ${AKS_RG_NAME} -AksClusterName ${AKS_CLUSTER_NAME} -DomainName ${DNS_DOMAIN_NAME} -HasSubDomainName:\$${HAS_SUBDOMAIN} -ApiKey ${API_KEY} -ApiSecret ${API_SECRET}")
    //     pwsh(script: './scripts/Deploy-Cert-Manager.ps1')
    //     pwsh(script: './scripts/Deploy-Manifests.ps1')
    //   }
    // }

    // stage('Test') {
    //   when {not { expression { params.TERRAFORM_DELETE} }}
    //   steps {
    //     pwsh(script: './scripts/Start-Test.ps1')
    //   }
    // }

  //   stage('Destroy-Terraform') {
  //     when { expression { params.TERRAFORM_DELETE} }
  //     options { retry(3) }
  //     steps {
  //       pwsh(script: './scripts/Destroy-Terraform.ps1')
  //     }
  //   }

  //   stage('Destroy-Storage') {
  //     when { expression { params.STORAGE_DELETE} }
  //     options { retry(3) }
  //     steps {
  //       pwsh(script: './scripts/Destroy-Storage.ps1')
  //     }
  //   }

  }

  // post {
  //   always {
  //     archiveArtifacts allowEmptyArchive: true, artifacts: "**/diff.txt"
  //     archiveArtifacts allowEmptyArchive: true, artifacts: '**/*-junit.xml'
  //     junit allowEmptyResults: true, testResults: '**/*-junit.xml'
  //   }
    // success {
    // }
    // failure {
    // }
    // aborted {
    // }
  // }

}
