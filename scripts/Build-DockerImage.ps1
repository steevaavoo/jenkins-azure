Push-Location .\app

# Building Docker image on Agent
$message = "Building docker image"
Write-Output "`nSTARTED: $message..."
docker build . -t adamrushuk/nodeapp:latest
Write-Output "FINISHED: $message."

Pop-Location
