# Build Docker image
Push-Location .\app
docker build . -t adamrushuk/nodeapp:multistage

# Show images
docker image ls

# Prune images
docker image prune

# Run new Docker image
docker run -p 8080:8080 -it --rm adamrushuk/nodeapp:multistage
