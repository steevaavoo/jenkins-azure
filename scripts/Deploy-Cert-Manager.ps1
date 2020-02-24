# Deploy cert-manager


#region cert-manager
# https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm
$message = "[HELM] Installing cert-manager"
Write-Output "STARTED: $message..."
# Install the CustomResourceDefinition resources separately
# kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.1/deploy/manifests/00-crds.yaml --namespace ingress-tls
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.1/deploy/manifests/00-crds.yaml

# Label the ingress-tls namespace to disable resource validation
# kubectl label namespace ingress-tls certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
# https://hub.helm.sh/charts/jetstack/cert-manager
helm install `
    cert-manager jetstack/cert-manager `
    --namespace ingress-tls `
    --version v0.13.1

# [OPTIONAL] args
# --set ingressShim.defaultIssuerName=letsencrypt `
# --set ingressShim.defaultIssuerKind=ClusterIssuer `
# --set extraArgs={"--dns01-recursive-nameservers=8.8.8.8:53,8.8.4.4:53"}

# Verify
# Show cert-manager pods
kubectl get pods -l app.kubernetes.io/instance=cert-manager -o wide --namespace ingress-tls

# Apply staging cluster-issuer
kubectl apply -n ingress-tls -f ./manifests/cluster-issuer-staging.yml
kubectl delete -n ingress-tls -f ./manifests/cluster-issuer-staging.yml
kubectl describe issuer letsencrypt-staging
kubectl describe certificate tls-secret
kubectl describe secret tls-secret

Write-Output "FINISHED: $message.`n"
#endregion
