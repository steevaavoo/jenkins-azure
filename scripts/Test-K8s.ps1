# Setting k8s current context
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing

# Testing kubectl
kubectl version --short

# Apply manifests
kubectl apply -f ./manifests