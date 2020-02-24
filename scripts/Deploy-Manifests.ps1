# Deploy kubernetes manifest files

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Replace tokens
./scripts/Replace-Tokens.ps1 -targetFilePattern './manifests/*.yml'

# Setting k8s current context
$message = "Merging AKS credentials"
Write-Output "`nSTARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing
Write-Output "FINISHED: $message."

# Testing kubectl
kubectl version --short

# Apply manifests
$message = "Applying Kubernetes manifests"
Write-Output "`nSTARTED: $message..."
# "ingress-tls" namespace created in Deploy-Ingress-Controller.ps1
# kubectl apply -n ingress-tls -f ./manifests
kubectl apply -n ingress-tls -f ./manifests/azure-vote.yml
kubectl apply -n ingress-tls -f ./manifests/ingress.yml
Write-Output "FINISHED: $message."

# Show resources
kubectl get all -n ingress-tls -l "app in (azure-vote, azure-vote-front, azure-vote-back)"
kubectl get ingress
kubectl describe ingress
kubectl get svc nginx-ingress-controller

# Test connection
curl -kivL -H 'Host: thehypepipe.co.uk' 'http://51.140.114.66'

# Show ingress URL
$url = kubectl get svc nginx-ingress-controller -n ingress-tls --ignore-not-found -o jsonpath="https://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to ingress URL: [$url]"
