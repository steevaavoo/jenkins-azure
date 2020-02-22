# Testing whether the Docker CLI / Docker socket mount worked

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

docker info
docker ps
