#!/bin/bash

# Check nginx logs
echo "Checking nginx logs..."
docker logs docker_nginx_1

# Check if the https.conf.template file exists
echo "Checking if https.conf.template exists..."
ls -la /root/Studio/docker/nginx/conf.d/https.conf.template

# If the file doesn't exist, create it
if [ ! -f /root/Studio/docker/nginx/conf.d/https.conf.template ]; then
    echo "Creating https.conf.template file..."
    mkdir -p /root/Studio/docker/nginx/conf.d/
    
    cat > /root/Studio/docker/nginx/conf.d/https.conf.template << 'EOF'
# Please do not directly edit this file. Instead, modify the .env variables related to NGINX configuration.

server {
    listen ${NGINX_SSL_PORT} ssl;
    server_name ${NGINX_SERVER_NAME};

    # SSL configuration
    ssl_certificate /etc/ssl/${NGINX_SSL_CERT_FILENAME};
    ssl_certificate_key /etc/ssl/${NGINX_SSL_CERT_KEY_FILENAME};
    ssl_protocols ${NGINX_SSL_PROTOCOLS};
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # HSTS (uncomment if you're sure)
    # add_header Strict-Transport-Security "max-age=63072000" always;

    # Root directory and index files
    root /var/www/html;
    index index.html index.htm;

    # Proxy settings
    include /etc/nginx/proxy.conf;

    # Include ACME challenge location for Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        try_files $uri =404;
    }

    # API service
    location /api/ {
        proxy_pass http://docker-api-1:5001/;
        include /etc/nginx/proxy.conf;
    }

    # Web service
    location / {
        proxy_pass http://docker-web-1:3000/;
        include /etc/nginx/proxy.conf;
    }
}
EOF
    echo "Created https.conf.template file"
fi

# Check if the SSL certificates exist
echo "Checking if SSL certificates exist..."
ls -la /root/Studio/docker/nginx/ssl/

# If the SSL certificates don't exist, create them
if [ ! -f /root/Studio/docker/nginx/ssl/dify.crt ] || [ ! -f /root/Studio/docker/nginx/ssl/dify.key ]; then
    echo "Creating SSL certificates..."
    mkdir -p /root/Studio/docker/nginx/ssl/
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /root/Studio/docker/nginx/ssl/dify.key -out /root/Studio/docker/nginx/ssl/dify.crt -subj "/CN=localhost"
    echo "Created SSL certificates"
fi

# Rebuild and restart the nginx container
echo "Rebuilding and restarting the nginx container..."
cd /root/Studio/docker
docker-compose build nginx
docker-compose up -d

# Check if the nginx container is running
echo "Checking if the nginx container is running..."
docker ps | grep nginx

# Check the nginx logs again
echo "Checking nginx logs again..."
docker logs docker_nginx_1 