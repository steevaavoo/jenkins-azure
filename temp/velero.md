# Velero Notes

## Contents

- [Velero Notes](#velero-notes)
  - [Contents](#contents)
  - [TODO](#todo)
  - [Prereqs](#prereqs)
  - [Install CLI](#install-cli)
  - [Install Server (CLI)](#install-server-cli)
  - [Install Server (Helm)](#install-server-helm)
  - [Troubleshooting](#troubleshooting)

## TODO

- [ ] Complete test backup / restore
- [ ] Test Velero Server install using Helm
- [ ] Configure and test Restic for AzureFile backup support: https://velero.io/docs/v1.2.0/restic/

## Prereqs

- Follow Azure setup guide: https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup

```powershell
# Vars
$location = "uksouth"
$backupResourceGroupName = ""
$storageAccountName = ""
$blobContainerName = "velero"
$aksAutoGenResourceGroup = ""

# Create Resource Group
az group create --name $backupResourceGroupName --location $location --verbose

# Create Storage Account
az storage account create `
  --name $storageAccountName `
  --resource-group $backupResourceGroupName `
  --sku Standard_LRS `
  --encryption-services blob `
  --https-only true `
  --kind BlobStorage `
  --access-tier Hot
  
# Create Blob Container
az storage container create -n $blobContainerName --public-access off --account-name $storageAccountName
```

## Install CLI

- Follow these steps: https://velero.io/docs/master/basic-install/
- Download binary: https://github.com/vmware-tanzu/velero/releases/tag/v1.2.0
- Move velero binary into your system path

```powershell
# Show version
velero version
```

## Install Server (CLI)

```powershell
# Create namespace
kubectl create namespace velero

# Check velero-plugin-for-microsoft-azure release version:
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/releases

# Example
# velero install \
#     --provider azure \
#     --plugins velero/velero-plugin-for-microsoft-azure:v1.0.0 \
#     --bucket $BLOB_CONTAINER \
#     --secret-file ./credentials-velero \
#     --backup-location-config resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,storageAccount=$AZURE_STORAGE_ACCOUNT_ID[,subscriptionId=$AZURE_BACKUP_SUBSCRIPTION_ID] \
#     --snapshot-location-config apiTimeout=<YOUR_TIMEOUT>[,resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,subscriptionId=$AZURE_BACKUP_SUBSCRIPTION_ID]

# View help
velero install -h

# Install
velero install `
    --provider azure `
    --plugins velero/velero-plugin-for-microsoft-azure:v1.0.0 `
    --bucket $blobContainerName `
    --secret-file ./temp/credentials-velero `
    --backup-location-config resourceGroup=$backupResourceGroupName,storageAccount=$storageAccountName `
    --snapshot-location-config apiTimeout=5m `
    --v 3

# Check
kubectl logs deployment/velero -n velero
kubectl get all -n velero
kubectl describe pod -n velero
kubectl get pod -n velero --watch

$podName = kubectl get pod -n velero -l component=velero -o jsonpath="{.items[0].metadata.name}"
kubectl logs $podName -n velero

# Cleanup (during error)
kubectl delete namespace velero
```

## Install Server (Helm)

```powershell
# Create namespace
kubectl create namespace velero
kubectl get ns

# Show current config
helm repo list

# Add repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# Show CLI help
helm install --namespace velero -f velero-values.yaml stable/velero
```

## Troubleshooting

Run the following checks:

```powershell
# Are your Velero server and daemonset pods running?
kubectl get pods -n velero

# Does your restic repository exist, and is it ready?
velero restic repo get
velero restic repo get REPO_NAME -o yaml

# Are there any errors in your Velero backup/restore?
velero backup describe BACKUP_NAME
velero backup logs BACKUP_NAME

velero restore describe RESTORE_NAME
velero restore logs RESTORE_NAME

# What is the status of your pod volume backups/restores?
kubectl -n velero get podvolumebackups -l velero.io/backup-name=BACKUP_NAME -o yaml
kubectl -n velero get podvolumerestores -l velero.io/restore-name=RESTORE_NAME -o yaml

# Is there any useful information in the Velero server or daemon pod logs?
kubectl -n velero logs deploy/velero
kubectl -n velero logs DAEMON_POD_NAME
```

**NOTE**: You can increase the verbosity of the pod logs by adding --log-level=debug as an argument to the
container command in the deployment/daemonset pod template spec.
