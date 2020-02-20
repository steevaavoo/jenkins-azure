# Deploy an AKS Ingress Controller

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Setting k8s current context
$message = "Merging AKS credentials"
Write-Output "`nSTARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing
Write-Output "FINISHED: $message."

# Create a namespace for your ingress resources
# kubectl create namespace ingress-basic 2>1 | Out-Null

# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress `
    --namespace ingress-basic `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl get service -l app=nginx-ingress --namespace ingress-basic
