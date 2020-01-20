Push-Location .\app

# Building Docker image on Agent
docker build . -t adamrushuk/nodeapp:latest

Pop-Location
