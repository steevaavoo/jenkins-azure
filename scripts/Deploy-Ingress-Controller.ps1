# Deploy an AKS Ingress Controller

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

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
kubectl create namespace ingress-tls

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

Write-Output "FINISHED: $message.`n"
#endregion



#region cert-manager
# https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm
$message = "[HELM] Installing cert-manager"
Write-Output "STARTED: $message..."
# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.1/deploy/manifests/00-crds.yaml --namespace ingress-tls


# Label the ingress-tls namespace to disable resource validation
kubectl label namespace ingress-tls certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
# https://hub.helm.sh/charts/jetstack/cert-manager
helm install cert-manager jetstack/cert-manager `
    --namespace cert-manager `
    --version v0.13.1 `
    --set ingressShim.defaultIssuerName=letsencrypt `
    --set ingressShim.defaultIssuerKind=ClusterIssuer

# Create a CA cluster issuer
kubectl apply -f ./manifests/cluster-issuer.yml --namespace ingress-tls

# Verify
kubectl get pods --namespace ingress-tls

Write-Output "FINISHED: $message.`n"
#endregion
