#region Jenkins blueocean
# Start Docker Desktop, or Docker-Machine (if using VirtualBox setup)
docker-machine start

# Load env vars for docker cli
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
az aks get-credentials --resource-group aks-rg --name stvaks1 --overwrite-existing

# See what's running
kubectl get node

kubectl get ns
kubectl get all, pv, pvc

# Custom Storage Class
# Show default yaml
kubectl get sc default -o yaml --export

# Create custom storage class (with "reclaimPolicy: Retain")
https://docs.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes

# Apply manifests
kubectl apply --validate -f ./manifests/azure-vote.yml

# Check
kubectl get sc, pvc, pv, all
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
kubectl create namespace ingress-basic

# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress `
    --namespace ingress-basic `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl get service -l app=nginx-ingress --namespace ingress-basic


helm repo add azure-samples https://azure-samples.github.io/helm-charts/

helm install aks-helloworld azure-samples/aks-helloworld --namespace ingress-basic

helm install aks-helloworld-two azure-samples/aks-helloworld `
    --namespace ingress-basic `
    --set title="AKS Ingress Demo" `
    --set serviceName="aks-helloworld-two"


kubectl apply -f ./manifests/ingress.yml
kubectl get ingress -A
helm list -A

kubectl get all -n ingress-basic

# Cleanup
helm uninstall aks-helloworld --namespace ingress-basic
helm uninstall aks-helloworld-two --namespace ingress-basic
helm uninstall nginx-ingress --namespace ingress-basic

#endregion Helm
