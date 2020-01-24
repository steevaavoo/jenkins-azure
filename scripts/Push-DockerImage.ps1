Push-Location .\app

# Logging in to container registry
az acr login --name $env:CONTAINER_REGISTRY_NAME

# Getting the fqdn for the acr
$acr_fqdn = "$env:CONTAINER_REGISTRY_NAME.azurecr.io"

# Tagging the app to the ACR
docker tag adamrushuk/nodeapp $acr_fqdn/$env:CONTAINER_REGISTRY_REPOSITORY

# Pushing the image to the ACR
docker push $acr_fqdn/$env:CONTAINER_REGISTRY_REPOSITORY

Pop-Location
