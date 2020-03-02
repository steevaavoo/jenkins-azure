#region Jenkins blueocean
# Start Docker Desktop, or Docker-Machine (if using VirtualBox setup)
docker-machine start

# Load env vars for docker cli
# may need to wait a minute after starting docker-machine vm
& docker-machine env --shell powershell default | Invoke-Expression
gci env:DOCKER*

# Open http://localhost:8080
# for docker-machine, use IP shown from "docker-machine ip"
# eg: http://192.168.99.104:8080/
docker run `
    --rm -d `
    -u root `
    -p 8080:8080 `
    -v jenkins-data:/var/jenkins_home `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -v /c/Users/$env:USERNAME:/home `
    --name jenkins `
    jenkinsci/blueocean

# Show logs to see admin unlock code
docker container logs jenkins

# Jenkins Plugins to install
# (only install once, as plugins persist due to volume mounts)
AnsiColor
Azure Credentials
PowerShell
Timestamper

# Use BlueOcean to add existing GitHub repo containing a Jenkinsfile
http://<JenkinsUrl>:8080/blue/create-pipeline

# Attach to container into a bash shell
docker container exec -it jenkins bash

# Pull latest image version
# (updates if local already present)
docker pull jenkinsci/blueocean

# Check image version
docker image ls jenkinsci/blueocean
# Show all image info
docker image inspect jenkinsci/blueocean
# Show image digest (to compare with Docker Hub DIGEST)
docker image inspect --format='{{.RepoDigests}}' jenkinsci/blueocean

# Check running containers
docker container ls

# Delete container called "jenkins"
docker kill jenkins

# Prune older image versions
docker image prune

# Stop
docker container stop jenkins

# Start
docker container start jenkins
#endregion Jenkins blueocean



#region Jenkins Agent
# https://hub.docker.com/r/adamrushuk/psjenkinsagent
# Build dated and latest tags
$dockerUser = "adamrushuk"
Push-Location .\agent
$tag = (Get-Date -Format "yyyy-MM-dd")
$dockerImage = "$dockerUser/psjenkinsagent"
$dockerImageAndTag = "$($dockerImage):$tag"
$dockerImageAndLatestTag = "$($dockerImage):latest"
docker build . -t $dockerImageAndTag
docker tag $dockerImageAndTag $dockerImageAndLatestTag

# Show
docker image ls $dockerUser/psjenkinsagent

# Push
docker push $dockerUser/psjenkinsagent:$tag ; docker push $dockerUser/psjenkinsagent:latest

# Run
docker run --rm -it --name jenkins-agent $dockerUser/psjenkinsagent:latest pwsh

# Run with mounted volume
docker run --rm -it -v ${PWD}:/data --workdir=/data --name jenkins-agent $dockerUser/psjenkinsagent:latest pwsh
#endregion Jenkins Agent



#region Node App
# Build
Push-Location .\app
docker build . -t adamrushuk/nodeapp:multistage

# Show
docker image ls adamrushuk/nodeapp

# Run
docker run -p 8080:8080 -it -d --rm --name nodeapp adamrushuk/nodeapp:multistage
# Open URL http://localhost:8080

# Kill
docker container ls
docker kill nodeapp
#endregion Node App



#region Kubectl
# Downloading latest credentials for AKS Cluster
az aks get-credentials --resource-group ruba-rg-aks-dev-001 --name ruba-aks-001 --overwrite-existing

# View AKS Dashboard
az aks browse --resource-group ruba-rg-aks-dev-001 --name ruba-aks-001

# * IMPORTANT
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace=ingress-tls

# See what's running
kubectl get node
kubectl get ns
kubectl get svc,ingress
kubectl get all,pv,pvc
kubectl get all,pv,pvc -o wide

# Custom Storage Class
# Show default yaml
kubectl get sc default -o yaml --export

# Create custom storage class (with "reclaimPolicy: Retain")
https://docs.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes

# Apply manifests
kubectl apply --validate -f ./manifests/azure-vote.yml

# Check
kubectl get sc,pvc,pv,all
kubectl get events --sort-by=.metadata.creationTimestamp -w
$podName = kubectl get pod -l app=azure-vote-front -o jsonpath="{.items[0].metadata.name}"
$podName = kubectl get pod -l app=azure-vote-back -o jsonpath="{.items[0].metadata.name}"
kubectl describe pod $podName
kubectl top pod $podName

# Wait for pod to be ready
kubectl get pod $podName --watch
kubectl get svc azure-vote-front --watch
#endregion Kubectl



#region Helm
# Create a namespace for your ingress resources
kubectl create namespace ingress-tls

# * IMPORTANT
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace=ingress-tls

# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress `
    --namespace ingress-tls `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl get service -l app=nginx-ingress --namespace ingress-tls


helm repo add azure-samples https://azure-samples.github.io/helm-charts/

helm install aks-helloworld azure-samples/aks-helloworld --namespace ingress-tls

helm install aks-helloworld-two azure-samples/aks-helloworld `
    --namespace ingress-tls `
    --set title="AKS Ingress Demo" `
    --set serviceName="aks-helloworld-two"


kubectl apply -f ./manifests/ingress.yml
kubectl get ingress -A
helm list --all-namespaces

helm status cert-manager

kubectl get all,ing

# Show secrets Helm uses to track release info
# sls is like grep for PowerShell
kubectl get secret | sls "NAME|helm.sh/release.v1"
#endregion Helm



#region Troubleshooting
# Check HTTP status codes
# Install cURL
choco install -y curl

# Show all curl options/switches
curl -h

# Common options
-I, --head          Show document info only
-i, --include       Include protocol response headers in the output
-k, --insecure      Allow insecure server connections when using SSL
-L, --location      Follow redirects
-s, --silent        Silent mode
-v, --verbose       Make the operation more talkative

# Test ingress
# curl -kivL -H 'Host: <HostUsedWithinIngressConfig>' 'http://<LoadBalancerExternalIp>'
curl -kivL -H 'Host: aks.thehypepipe.co.uk' 'http://51.140.114.66'

# Should return "200" if Default backend is running ok
curl -I https://aks.thehypepipe.co.uk/healthz

# Should return "200", maybe "404" if configured wrong
curl -I https://aks.thehypepipe.co.uk/helloworld

# Show HTML output
curl https://aks.thehypepipe.co.uk/helloworld
curl https://aks.thehypepipe.co.uk

# Misc
curl -I https://aks.thehypepipe.co.uk/helloworld
curl -I https://aks.thehypepipe.co.uk
# Ignore cert errors
curl -i -k https://aks.thehypepipe.co.uk/helloworld
curl -i -k https://aks.thehypepipe.co.uk

# Check SSL
# Use www.ssllabs.com for thorough SSL cert check
https://www.ssllabs.com/ssltest/analyze.html?d=aks.thehypepipe.co.uk

# openssl s_client -connect host:port -status
# openssl s_client -connect host:port -status [-showcerts]
openssl s_client -connect aks.thehypepipe.co.uk:443 | sls "CN =|error"
openssl s_client -connect aks.thehypepipe.co.uk:443 -status -showcerts
openssl s_client -connect aks.thehypepipe.co.uk:443 -status

# ! COMMON ISSUES
# - default-backend-service will show when ingress not configured correctly or it does not have endpoints
# - ensure the ingress namespace matches the service namespaces

# * IMPORTANT
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace=ingress-tls

# Check the Ingress Resource Events
$ingressControllerPodName = kubectl get pod -l component=controller -o jsonpath="{.items[0].metadata.name}"
kubectl get ing
kubectl get ing ingress -o yaml
kubectl describe ing ingress
kubectl describe ing ingress-static
kubectl get svc nginx-ingress-controller
kubectl describe pod $ingressControllerPodName

# Check the Ingress Controller Logs
kubectl logs -f -l component=controller --all-containers=true

# Check the NginX Configuration
# NginX vscode extension: https://marketplace.visualstudio.com/items?itemName=raynigon.nginx-formatter
# Search nginx.conf for location {} blocks, including "$service_name" etc
# Ensure $namespace, $ingress_name, $service_name, and $service_port are correct
kubectl get pods
kubectl exec -it $ingressControllerPodName cat /etc/nginx/nginx.conf > nginx.conf

# Check Stats within Controller pod
kubectl exec -it $ingressControllerPodName /bin/bash
curl http://localhost/nginx_status

# Check if used Services Exist
kubectl get svc --all-namespaces

# Check default backend pod
kubectl describe pods -l component=default-backend


# Debug Logging
# Using the flag --v=XX it is possible to increase the level of logging.
# This is performed by editing the deployment
kubectl get deploy

# Instruct kubectl to edit using vscode
$env:KUBE_EDITOR = 'code --wait'
kubectl edit deploy nginx-ingress-controller

# Add --v=X to "- args", where X is an integer
--v=2 shows details using diff about the changes in the configuration in nginx
--v=3 shows details about the service, Ingress rule, endpoint changes and it dumps the nginx configuration in JSON format
--v=5 configures NGINX in debug mode



# Debugging cert-manager
# Show all resource types
kubectl api-resources
kubectl api-resources | sls "cert-manager.io"

# Show cert-manager resources
kubectl get challenges,orders,certificaterequests,certificates,clusterissuers,issuers -A
kubectl get challenges -A -o wide
kubectl get orders -A -o wide
kubectl get certificaterequests -A -o wide
kubectl get certificates -A -o wide
kubectl get clusterissuers -A -o wide
kubectl get issuers -A -o wide

# Check Custom Resource Definitions
kubectl get crd

# Show cert-manager pods
kubectl get pods -l app.kubernetes.io/instance=cert-manager -o wide

# Check pod status and events
$certManagerPod = kubectl get pod -l app.kubernetes.io/name=cert-manager -o jsonpath="{.items[0].metadata.name}"
$caInjectorPod = kubectl get pod -l app.kubernetes.io/name=cainjector -o jsonpath="{.items[0].metadata.name}"
$webhookPod = kubectl get pod -l app.kubernetes.io/name=webhook -o jsonpath="{.items[0].metadata.name}"
kubectl describe pods $certManagerPod
kubectl describe pods $caInjectorPod
kubectl describe pods $webhookPod

# Check pod status and events
# kubectl logs -f -l LABEL=VALUE --all-containers=true
kubectl logs -f $certManagerPod --all-containers=true
kubectl logs -f $caInjectorPod --all-containers=true
kubectl logs -f $webhookPod --all-containers=true

# Check DNS from within pods
kubectl exec -it $certManagerPod cert-manager sh
kubectl exec -it $caInjectorPod sh
kubectl exec -it $webhookPod sh
# Check dns lookup
nslookup aks.thehypepipe.co.uk

# TODO WIP
# Main issue in initial Jenkins build when running:
# "kubectl apply -f ./manifests/cluster-issuer.yml --namespace ingress-tls"
[2020-02-22T12:58:13.628Z] Error from server (InternalError): error when creating "./manifests/cluster-issuer.yml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": Post https://cert-manager-webhook.ingress-tls.svc:443/mutate?timeout=30s: dial tcp 10.0.171.89:443: connect: connection refused

# Works second attempt
clusterissuer.cert-manager.io/letsencrypt configured

# Check cert issuer
# ClusterIssuer has cluster-wide scope
# Issuer has namespace scope
kubectl get ClusterIssuer -A
kubectl get Issuer -A

kubectl get customresourcedefinitions
kubectl get crd
kubectl get clusterissuers.cert-manager.io -A
kubectl get issuers.cert-manager.io -A

# Check webhook api
kubectl get apiservice v1beta1.webhook.certmanager.k8s.io
kubectl get apiservice | sls "webhook"


# Check ClusterIssuer is READY
# - Status > Conditions
# - Message: The ACME account was registered with the ACME server
kubectl get ClusterIssuer -A -o wide
kubectl describe ClusterIssuer letsencrypt-prod
kubectl describe ClusterIssuer letsencrypt-staging

# Check Certificate is READY
# - Status > Conditions
# - Message: Certificate is up to date and has not expired
kubectl get cert -A -o wide
kubectl describe cert tls-secret
kubectl get cert tls-secret --watch
kubectl delete cert tls-secret

# Check Secret
# Annotations should include multiple cert-manager.io entries
kubectl get secret tls-secret -o wide
kubectl describe secret tls-secret


# Recreate ingress
kubectl delete -f ./manifests/ingress.yml
kubectl apply -f ./manifests/ingress.yml

kubectl get ing -o wide
kubectl describe ingress
#endregion Troubleshooting



#region Cleanup
kubectl get ns
kubectl get all,configmap,pv,pvc --namespace ingress-tls
helm list --namespace ingress-tls

kubectl delete namespace ingress-tls

helm uninstall aks-helloworld --namespace ingress-tls
helm uninstall aks-helloworld-two --namespace ingress-tls
helm uninstall nginx-ingress --namespace ingress-tls

kubectl get ns
kubectl get all --namespace ingress-tls
helm list --namespace ingress-tls
#endregion Cleanup
