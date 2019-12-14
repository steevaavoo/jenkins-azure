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
- [ ] Use cli to destroy storage (optional)
- [ ] Add retry block to Destroy stage
- [ ] Add Pester tests with junit output
- [ ] Add Helm for Kubernetes releases
