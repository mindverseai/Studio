#!/bin/sh
set -e

# Create required directories
mkdir -p /var/www/html
mkdir -p /etc/letsencrypt

# Copy configuration templates
cp /docker-entrypoint.d/conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template
cp /docker-entrypoint.d/conf.d/https.conf.template /etc/nginx/conf.d/https.conf.template

# Process templates with environment variables
envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME} ${NGINX_SSL_PROTOCOLS} ${NGINX_PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME} ${NGINX_SSL_PROTOCOLS}' < /etc/nginx/conf.d/https.conf.template > /etc/nginx/conf.d/https.conf

# Generate nginx configuration
envsubst '${NGINX_SERVER_NAME} ${NGINX_HTTPS_ENABLED} ${NGINX_SSL_PORT} ${NGINX_PORT} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME} ${NGINX_SSL_PROTOCOLS} ${NGINX_WORKER_PROCESSES} ${NGINX_CLIENT_MAX_BODY_SIZE} ${NGINX_KEEPALIVE_TIMEOUT} ${NGINX_PROXY_READ_TIMEOUT} ${NGINX_PROXY_SEND_TIMEOUT}' < /docker-entrypoint.d/nginx.conf.template > /etc/nginx/nginx.conf

# Generate proxy configuration
envsubst '${NGINX_PROXY_READ_TIMEOUT} ${NGINX_PROXY_SEND_TIMEOUT}' < /docker-entrypoint.d/proxy.conf.template > /etc/nginx/proxy.conf

# Generate HTTPS configuration if enabled
if [ "${NGINX_HTTPS_ENABLED}" = "true" ]; then
    # Check if we have certbot certificates
    if [ -d "/etc/letsencrypt/live/${CERTBOT_DOMAIN}" ]; then
        # Use certbot certificates
        envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_PROTOCOLS}' < /etc/nginx/conf.d/https.conf.template | \
        sed -e "s|ssl_certificate.*|ssl_certificate /etc/letsencrypt/live/${CERTBOT_DOMAIN}/fullchain.pem;|" \
            -e "s|ssl_certificate_key.*|ssl_certificate_key /etc/letsencrypt/live/${CERTBOT_DOMAIN}/privkey.pem;|" \
            > /etc/nginx/conf.d/https.conf
    else
        # Use default certificates
        envsubst '${NGINX_SERVER_NAME} ${NGINX_SSL_PORT} ${NGINX_SSL_PROTOCOLS} ${NGINX_SSL_CERT_FILENAME} ${NGINX_SSL_CERT_KEY_FILENAME}' < /etc/nginx/conf.d/https.conf.template > /etc/nginx/conf.d/https.conf
    fi
fi

# Start nginx
exec "$@"