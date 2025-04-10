#!/bin/sh

echo "🔒 Checking SSL Certificate Status..."
echo "----------------------------------------"

# Get the domain from the current directory name or use a default
DOMAIN=$(basename $(pwd))
echo "🌐 Domain: $DOMAIN"

# Check certbot container status
CERTBOT_CONTAINER=$(docker ps -a --filter "name=certbot" --format "{{.Names}}")
CERTBOT_STATUS=$(docker ps -a --filter "name=certbot" --format "{{.Status}}")

if [ -z "$CERTBOT_CONTAINER" ]; then
    echo "❌ Certbot container not found!"
    exit 1
fi

echo "📦 Certbot container: $CERTBOT_CONTAINER"
echo "📊 Status: $CERTBOT_STATUS"

if [[ $CERTBOT_STATUS == *"Restarting"* ]]; then
    echo "⚠️  Warning: Certbot container is restarting. This might indicate an issue."
    echo "Checking container logs for errors..."
    docker logs $CERTBOT_CONTAINER --tail 20
    
    # Check if the issue is the renewal prompt
    if docker logs $CERTBOT_CONTAINER --tail 50 | grep -q "What would you like to do?"; then
        echo -e "\n🔧 Issue detected: Certbot is waiting for user input during renewal."
        echo "To fix this, you need to run the renewal with the --non-interactive flag."
        echo -e "\nTry this command to fix the issue:"
        echo "docker exec $CERTBOT_CONTAINER certbot renew --non-interactive"
    fi
fi

# Check certificate expiry date
echo -e "\n📅 Checking certificate expiry date..."
if docker exec $CERTBOT_CONTAINER certbot certificates 2>/dev/null; then
    echo "✅ Certificate information retrieved successfully"
else
    echo "❌ Could not retrieve certificate information. Container might be having issues."
    echo "Checking certificate files directly..."
    docker exec $CERTBOT_CONTAINER ls -l /etc/letsencrypt/live/ 2>/dev/null || echo "No live certificates found"
fi

# Check renewal configuration
echo -e "\n🔄 Checking renewal configuration..."
docker exec $CERTBOT_CONTAINER ls -l /etc/letsencrypt/renewal/ 2>/dev/null || echo "No renewal configuration found"

# Check if auto-renewal is configured in cron
echo -e "\n⏰ Checking auto-renewal schedule..."
docker exec $CERTBOT_CONTAINER crontab -l 2>/dev/null | grep certbot || echo "No cron jobs found for certbot"

echo -e "\n----------------------------------------"
echo "💡 Note: Certbot typically renews certificates when they are within 30 days of expiry"
echo "💡 You can manually renew certificates using: docker exec $CERTBOT_CONTAINER certbot renew --non-interactive"
echo "💡 To fix restarting issues, check the logs with: docker logs $CERTBOT_CONTAINER"
echo "💡 To stop the container from restarting: docker stop $CERTBOT_CONTAINER && docker rm $CERTBOT_CONTAINER" 