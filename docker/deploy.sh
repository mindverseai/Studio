#!/bin/bash

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create necessary directories
sudo mkdir -p /var/www/html
sudo mkdir -p /etc/ssl

# Copy environment file
cp .env.example .env

# Update environment variables
sed -i 's/CERTBOT_EMAIL=your_email@example.com/CERTBOT_EMAIL=jack@mind-verse.de/' .env
sed -i 's/CERTBOT_DOMAIN=admin-studio.mind-verse.de/CERTBOT_DOMAIN=admin-studio.mind-verse.de/' .env

# Start the application
docker-compose down
docker-compose up -d

# Wait for services to start
sleep 10

# Check if services are running
docker-compose ps

echo "Deployment completed. Please check the logs for any errors." 