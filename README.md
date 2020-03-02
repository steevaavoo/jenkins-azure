# jenkins-azure

## Goals

- [x] Install Docker Desktop
- [x] Configure Docker Agent (Create Ephemeral Agent behaviours)
  - [x] Create Docker image with all necessary tools for this pipeline
    - [x] azure cli
    - [x] terraform
    - [x] docker cli
- [x] Is there a GitHub build pipeline status plugin
- [x] Create custom nginx Docker container and upload to Azure container registry
- [x] Deploy custom container in K8s
- [x] Use cli to destroy storage (optional)
- [x] Add retry block to Destroy stage
- [x] Update DNS record with App IP
- [x] Add example of using an external script with `returnStdout` method
- [x] Only prompt to continue if TF changes exist
- [x] Add prereq steps, eg: Azure Service Principal (see below)
- [x] Create a multi-stage Docker image build, to reduce image size (docker push takes too long)
- [x] Update Terraform to use latest version of Azure provider
- [x] Update Jenkins Agent dockerfile with latest util versions, and push to Docker Hub
- [x] Add improved output to all scripts, esp. az cli scripts with no current output (`Destroy-Storage.ps1`)
- [x] Add [`az acr build`](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az-acr-build) step - instead of local docker build / push
- [x] Add Pester tests with junit output
- [x] Add dynamic check to skip Docker build stage if image tag hasn't changed
- [x] Fix ingress rules
- [x] Add Helm for Kubernetes releases
- [x] Add TLS ingress to support HTTPS certs using LetsEncrypt service
- [x] Add AKS autoscaling (1-3 nodes)
- [x] Enable Kubernetes dashboard
- [x] Ensure all resource names adhere to Azure naming conventions:  
  https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
- [x] Add SSH key creation and outputs
- [x] Add `$ErrorActionPreference = "Stop"` to every PowerShell script
- [x] Add Terraform diff summary within input prompt (single line summary)
- [x] Add Terraform diff summary details within input prompt (one line per resource)
- [x] Add support for DNS subdomains, eg `aks.thehypepipe.co.uk`
- [x] Troubleshoot `Waiting for CertificateRequest "tls-secret-1881013061" to complete`
- [x] Add boolean param to switch between staging and prod LetsEncrypt SSL cert issuer services:  
  https://letsencrypt.org/docs/staging-environment/
- [x] Add integration test to check staging cert is issued by `Fake LE Intermediate` server
- [x] Troubleshoot `Connection refused 172.17.0.3:0` in cert test
- [x] Add integration test to check prod cert is issued by `Let's Encrypt Authority` server
- [x] Link CI_DEBUG param to verbose messaging. When CI_DEBUG is false, minimal output should show in logs
- [ ] Add clock (or another better) example node app instead of a one sentence website:  
  https://github.com/jaydestro/react-clock-basic (can test website headers, and/or datetime present)
- [ ] Add a StatefulSet app example (research below):  
  - https://velero.io/blog/velero-v1-1-stateful-backup-vsphere/
  - https://github.com/helm/charts/tree/master/stable/wordpress
  - https://aksworkshop.io/
- [ ] Add Velero backup (after adding StatefulSet example)
- [ ] Fix `Replace-Tokens.ps1` adding blank lines to YAML files
- [ ] Complete this README with proper usage instructions

```powershell
# Login to your target Azure environment
az login

# Create a Service Principle named "jenkins"
# outputting the required info for future use
az ad sp create-for-rbac --name jenkins --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"

# output subscription id
az account show --query "{ subscription_id: id }"
```
