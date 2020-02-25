# Deploy kubernetes manifest files

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Replace tokens
<#
    # local testing - manually add env vars
    $env:EMAIL_ADDRESS = "admin@domain.com"
    $env:DNS_DOMAIN_NAME = "aks.thehypepipe.co.uk"
    $env:CERT_API_ENVIRONMENT = "staging"
#>
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

# ClusterIssuers
kubectl apply -f ./manifests/cluster-issuer-staging.yml
kubectl apply -f ./manifests/cluster-issuer-prod.yml

# Applications
kubectl apply -n ingress-tls -f ./manifests/azure-vote.yml
kubectl apply -n ingress-tls -f ./manifests/nodeapp.yml

# Ingress
kubectl apply -n ingress-tls -f ./manifests/ingress.yml

<#
kubectl delete -n ingress-tls -f ./manifests/ingress.yml
kubectl delete -n ingress-tls -f ./manifests/azure-vote.yml
#>
Write-Output "FINISHED: $message."
