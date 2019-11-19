Push-Location .\app
# Building Docker image on Agent
docker build . -t steevaavoo/nodeapp:latest
Pop-Location