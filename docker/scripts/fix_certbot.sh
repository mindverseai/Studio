#!/bin/sh

echo "🔧 Fixing Certbot Container Issue..."
echo "----------------------------------------"

# Stop and remove the restarting container
echo "🛑 Stopping and removing the restarting certbot container..."
docker stop docker-certbot-1
docker rm docker-certbot-1

# Start a new certbot container with non-interactive mode
echo "🚀 Starting a new certbot container with non-interactive mode..."
docker-compose up -d certbot

# Wait for the container to start
echo "⏳ Waiting for the container to start..."
sleep 5

# Check if the container is running properly
CERTBOT_STATUS=$(docker ps --filter "name=certbot" --format "{{.Status}}")
if [[ $CERTBOT_STATUS == *"Up"* ]]; then
    echo "✅ Certbot container is now running properly"
else
    echo "❌ Certbot container is still having issues"
    echo "Checking logs for more information..."
    docker logs docker-certbot-1 --tail 20
fi

# Run a non-interactive renewal to ensure it works
echo "🔄 Running a non-interactive certificate renewal..."
docker exec docker-certbot-1 certbot renew --non-interactive

echo "----------------------------------------"
echo "💡 If the container is still having issues, you may need to check the docker-compose configuration"
echo "💡 You can check the certificate status with: ./docker/scripts/check_ssl.sh" 