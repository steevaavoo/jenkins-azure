# Building Docker image on Agent
Push-Location .\app
docker build . -t steevaavoo/nodeapp:latest
# This line for debug
docker image ls
Pop-Location