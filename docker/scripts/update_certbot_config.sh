#!/bin/sh

echo "🔧 Updating Certbot Configuration..."
echo "----------------------------------------"

# Check if docker-compose.yaml exists
if [ ! -f "docker-compose.yaml" ]; then
    echo "❌ docker-compose.yaml not found in the current directory"
    exit 1
fi

# Create a backup of the docker-compose.yaml file
echo "📦 Creating backup of docker-compose.yaml..."
cp docker-compose.yaml docker-compose.yaml.backup

# Update the certbot service configuration
echo "🔄 Updating certbot service configuration..."
sed -i 's/certbot renew/certbot renew --non-interactive/g' docker-compose.yaml

# Check if the update was successful
if grep -q "certbot renew --non-interactive" docker-compose.yaml; then
    echo "✅ Certbot configuration updated successfully"
else
    echo "❌ Failed to update certbot configuration"
    echo "Restoring backup..."
    cp docker-compose.yaml.backup docker-compose.yaml
    exit 1
fi

echo "----------------------------------------"
echo "💡 The certbot service has been updated to use non-interactive mode"
echo "💡 You can restart the certbot container with: docker-compose up -d certbot"
echo "💡 To verify the changes, run: ./docker/scripts/check_ssl.sh" 