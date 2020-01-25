Push-Location .\app

# Logging in to container registry
az acr login --name $env:ACR_NAME

# Local build
# Format: repo/image:tag
# docker build . -t adamrushuk/nodeapp:latest

# ACR build
$message = "Building docker image via ACR"
Write-Output "STARTED: $message..."
az acr build -t $env:CONTAINER_IMAGE_TAG_FULL -r $env:ACR_NAME .
Write-Output "FINISHED: $message."

Pop-Location
