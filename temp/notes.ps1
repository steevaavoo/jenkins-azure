#region Jenkins blueocean
# Open http://localhost:8080
docker run `
    --rm -d `
    -u root `
    -p 8080:8080 `
    -v jenkins-data:/var/jenkins_home `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -v ${HOME}:/home `
    --name jenkins `
    jenkinsci/blueocean

# Jenkins Plugins to install
# (only install once, as plugins persist due to volume mounts)
AnsiColor
Azure Credentials
PowerShell
Timestamper

# Show logs to see admin unlock code
docker container logs jenkins

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
Push-Location .\agent
$tag = "2020-01-25"
$dockerImage = "adamrushuk/psjenkinsagent"
$dockerImageAndTag = "$($dockerImage):$tag"
$dockerImageAndLatestTag = "$($dockerImage):latest"
docker build . -t $dockerImageAndTag
docker tag $dockerImageAndTag $dockerImageAndLatestTag

# Show
docker image ls adamrushuk/psjenkinsagent

# Push
docker push adamrushuk/psjenkinsagent:$tag ; docker push adamrushuk/psjenkinsagent:latest

# Run
docker run --rm -it --name jenkins-agent adamrushuk/psjenkinsagent:latest pwsh
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
