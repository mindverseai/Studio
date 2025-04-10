#!/bin/sh

echo "🔒 Checking SSL Certificate Status..."
echo "----------------------------------------"

# Get the domain from the current directory name or use a default
DOMAIN=$(basename $(pwd))
echo "🌐 Domain: $DOMAIN"

# Check if certbot container is running
CERTBOT_CONTAINER=$(docker ps --filter "name=certbot" --format "{{.Names}}")
if [ -z "$CERTBOT_CONTAINER" ]; then
    echo "❌ Certbot container is not running!"
    exit 1
fi

echo "✅ Certbot container is running: $CERTBOT_CONTAINER"

# Check certificate expiry date
echo "📅 Checking certificate expiry date..."
docker exec $CERTBOT_CONTAINER certbot certificates

# Check renewal configuration
echo -e "\n🔄 Checking renewal configuration..."
docker exec $CERTBOT_CONTAINER ls -l /etc/letsencrypt/renewal/

# Check if auto-renewal is configured in cron
echo -e "\n⏰ Checking auto-renewal schedule..."
docker exec $CERTBOT_CONTAINER crontab -l | grep certbot

echo -e "\n----------------------------------------"
echo "💡 Note: Certbot typically renews certificates when they are within 30 days of expiry"
echo "💡 You can manually renew certificates using: docker exec $CERTBOT_CONTAINER certbot renew" 