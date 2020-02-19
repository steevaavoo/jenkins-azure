Push-Location .\app

# Logging in to container registry
az acr login --name $env:ACR_NAME

# Skip build if tag already exists in acr
$acrRepoTags = az acr repository show-tags --name $env:ACR_NAME --repository $env:CONTAINER_IMAGE_NAME | ConvertFrom-Json

if (($env:CONTAINER_IMAGE_TAG -notin $acrRepoTags) -or ($env:FORCE_CONTAINER_BUILD -eq "true")) {

    Write-Output "FORCE_CONTAINER_BUILD param: [$env:FORCE_CONTAINER_BUILD]"

    # Local build
    # Format: repo/image:tag
    # docker build . -t adamrushuk/nodeapp:latest

    # ACR build
    $message = "Building docker image via ACR"
    Write-Output "STARTED: $message..."
    az acr build -t $env:CONTAINER_IMAGE_TAG_FULL -r $env:ACR_NAME .
    Write-Output "FINISHED: $message."
} else {
    Write-Output "SKIPPING: Building docker image via ACR...[CONTAINER_IMAGE_TAG '$env:CONTAINER_IMAGE_TAG'] already exists."
}

Pop-Location
