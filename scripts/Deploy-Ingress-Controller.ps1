# Deploy an AKS Ingress Controller

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Setting k8s current context
$message = "Merging AKS credentials"
Write-Output "STARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing
Write-Output "FINISHED: $message."

# Create a namespace for your ingress resources
kubectl create namespace ingress-basic



#region NGINX
# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress `
    --namespace ingress-basic `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.extraArgs.v=3

# [OPTIONAL] args
# --set controller.extraArgs.v=3 `
# --set controller.replicaCount=2 `
#endregion



#region cert-manager
# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml --namespace ingress-basic

# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager `
    --namespace ingress-basic `
    --version v0.12.0 jetstack/cert-manager `
    --set ingressShim.defaultIssuerName=letsencrypt `
    --set ingressShim.defaultIssuerKind=ClusterIssuer

# Create a CA cluster issuer
kubectl apply -f cluster-issuer.yml --namespace ingress-basic
#endregion
