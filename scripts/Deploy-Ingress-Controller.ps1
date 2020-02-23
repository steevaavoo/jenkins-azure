# Deploy an AKS Ingress Controller

# Setting k8s current context
$message = "Merging AKS credentials"
Write-Output "STARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing
Write-Output "FINISHED: $message.`n"

# Create a namespace for your ingress resources
$message = "Creating namespace"
Write-Output "STARTED: $message..."
kubectl create namespace ingress-tls
Write-Output "FINISHED: $message.`n"


#region NGINX
$message = "[HELM] Installing NGINX ingress controller"
Write-Output "STARTED: $message..."

# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress `
    --namespace ingress-tls `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.extraArgs.v=3

# [OPTIONAL] args
# --set controller.extraArgs.v=3 `
# --set controller.replicaCount=2 `

Write-Output "FINISHED: $message."
#endregion
