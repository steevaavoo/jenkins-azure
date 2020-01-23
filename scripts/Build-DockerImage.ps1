Push-Location .\app

# Building Docker image on Agent
$message = "Building docker image"
Write-Output "STARTED: $message..."
docker build . -t adamrushuk/nodeapp:latest
Write-Output "FINISHED: $message."

Pop-Location
