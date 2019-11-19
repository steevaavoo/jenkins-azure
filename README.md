# jenkins-azure

## Goals

- [x] Install Docker Desktop
- [ ] Configure Docker Agent (Create Ephemeral Agent behaviours)
  - [ ] Create Docker image with all necessary tools for this pipeline
    - [ ] azure cli
    - [ ] terraform
    - [ ] docker cli
- [ ] Is there a GitHub build pipeline status plugin
- [x] Create custom nginx Docker container and upload to Azure container registry
- [ ] Deploy custom container in K8s
- [ ] Add retry block to Destroy stage
- [ ] Use cli to destroy storage (optional)
