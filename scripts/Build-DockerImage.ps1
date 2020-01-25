Push-Location .\app

# Logging in to container registry
az acr login --name $env:CONTAINER_REGISTRY_NAME

# Building Docker image on Agent
$message = "Building docker image"
Write-Output "`nSTARTED: $message..."
# Format: repo/image:tag
# docker build . -t adamrushuk/nodeapp:latest
az acr build -t $env:CONTAINER_REGISTRY_REPOSITORY:$env:CONTAINER_IMAGE_TAG -r $env:CONTAINER_REGISTRY_NAME .
Write-Output "FINISHED: $message."

Pop-Location
