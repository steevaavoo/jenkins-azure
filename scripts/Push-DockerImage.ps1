Push-Location .\app

# Logging in to container registry
az acr login --name $env:CONTAINER_REGISTRY_NAME

# Getting the fqdn for the acr
$acr_fqdn = (az acr list --query [0].loginServer -o tsv)

# Tagging the app to the ACR
docker tag steevaavoo/nodeapp $acr_fqdn/samples/nodeapp

# Pushing the image to the ACR
docker push $acr_fqdn/samples/nodeapp

Pop-Location