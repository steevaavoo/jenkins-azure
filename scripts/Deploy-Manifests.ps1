# Replace tokens
./scripts/Replace-Tokens.ps1 -targetFilePattern './manifests/*.yml'

# Setting k8s current context
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing

# Testing kubectl
kubectl version --short

# Apply manifests
kubectl apply -f ./manifests

# Assemble and show App URL
$appurl = kubectl get svc nodeapp --ignore-not-found -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to app with: $appurl"