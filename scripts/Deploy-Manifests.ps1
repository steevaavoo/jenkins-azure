# Deploy kubernetes manifest files

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Replace tokens
<#
    # local testing - manually add env vars
    $env:EMAIL_ADDRESS = "adamrushuk@gmail.com"
    $env:DNS_DOMAIN_NAME = "aks.thehypepipe.co.uk"
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
kubectl apply -n ingress-tls -f ./manifests/azure-vote.yml
kubectl apply -n ingress-tls -f ./manifests/ingress-staging.yml
kubectl apply -f ./manifests/cluster-issuer-staging.yml
kubectl apply -f ./manifests/cluster-issuer-prod.yml
<#
kubectl delete -n ingress-tls -f ./manifests/ingress.yml
kubectl delete -n ingress-tls -f ./manifests/azure-vote.yml
#>
Write-Output "FINISHED: $message."

# Show resources
kubectl get all -n ingress-tls -l "app in (azure-vote, azure-vote-front, azure-vote-back)"
kubectl get ingress
kubectl describe ingress

kubectl get svc nginx-ingress-controller
kubectl describe svc nginx-ingress-controller

kubectl get ClusterIssuer
kubectl describe ClusterIssuer

# Check Annotations for "cert-manager" entries
kubectl get secret tls-secret
kubectl describe secret tls-secret

kubectl get cert
kubectl describe cert

# Update to use prod ClusterIssuer
kubectl delete -n ingress-tls -f ./manifests/ingress-staging.yml
kubectl apply -n ingress-tls -f ./manifests/ingress-prod.yml

# Show cert-manager resources
kubectl get challenges,orders,certificaterequests,certificates,clusterissuers,issuers -A

kubectl get ingress
kubectl describe ingress

# Test connection
kubectl get svc nginx-ingress-controller
curl -kivL -H 'Host: aks.thehypepipe.co.uk' 'https://51.140.114.66'

# Show ingress URL
$url = kubectl get svc nginx-ingress-controller -n ingress-tls --ignore-not-found -o jsonpath="https://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to ingress URL: $url"
