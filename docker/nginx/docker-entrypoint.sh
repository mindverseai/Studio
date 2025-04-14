#!/bin/sh
set -e

# Create required directories
mkdir -p /var/www/html
mkdir -p /etc/letsencrypt

# Copy configuration templates
cp /docker-entrypoint.d/conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template
cp /docker-entrypoint.d/conf.d/https.conf.template /etc/nginx/conf.d/https.conf.template

# Process templates with environment variables
envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME} ${NGINX_SSL_PROTOCOLS}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME} ${NGINX_SSL_PROTOCOLS}' < /etc/nginx/conf.d/https.conf.template > /etc/nginx/conf.d/https.conf

# Generate nginx configuration
envsubst '${NGINX_SERVER_NAME} ${NGINX_HTTPS_ENABLED} ${NGINX_SSL_PORT} ${NGINX_PORT} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME} ${NGINX_SSL_PROTOCOLS} ${NGINX_WORKER_PROCESSES} ${NGINX_CLIENT_MAX_BODY_SIZE} ${NGINX_KEEPALIVE_TIMEOUT} ${NGINX_PROXY_READ_TIMEOUT} ${NGINX_PROXY_SEND_TIMEOUT}' < /docker-entrypoint.d/nginx.conf.template > /etc/nginx/nginx.conf

# Generate proxy configuration
envsubst '${NGINX_PROXY_READ_TIMEOUT} ${NGINX_PROXY_SEND_TIMEOUT}' < /docker-entrypoint.d/proxy.conf.template > /etc/nginx/proxy.conf

# Create a default server block for HTTP
cat > /etc/nginx/conf.d/default.conf << EOF
server {
    listen ${NGINX_PORT};
    server_name ${NGINX_SERVER_NAME};
    
    # Include ACME challenge location for Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        try_files \$uri =404;
    }
    
    # API service
    location /api/ {
        proxy_pass http://docker-api-1:5001/;
    }
    
    # Web service
    location / {
        proxy_pass http://docker-web-1:3000/;
    }
    
    # Redirect all other HTTP traffic to HTTPS if HTTPS is enabled
    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }
}
EOF

# Generate HTTPS configuration if enabled
if [ "${NGINX_HTTPS_ENABLED}" = "true" ]; then
    # Check if we have certbot certificates
    if [ -d "/etc/letsencrypt/live/${CERTBOT_DOMAIN}" ]; then
        # Use certbot certificates
        envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_PROTOCOLS}' < /etc/nginx/https.conf.template | \
        sed -e "s|ssl_certificate.*|ssl_certificate /etc/letsencrypt/live/${CERTBOT_DOMAIN}/fullchain.pem;|" \
            -e "s|ssl_certificate_key.*|ssl_certificate_key /etc/letsencrypt/live/${CERTBOT_DOMAIN}/privkey.pem;|" \
            > /etc/nginx/conf.d/https.conf
    else
        # Use default certificates
        envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_PROTOCOLS} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME}' < /etc/nginx/https.conf.template > /etc/nginx/conf.d/https.conf
    fi
fi

# Start nginx
exec "$@"