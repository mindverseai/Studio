#!/bin/bash
set -e

# Function to generate Nginx configuration
generate_nginx_config() {
    # Process templates
    env_vars=$(printenv | cut -d= -f1 | sed 's/^/$/g' | paste -sd, -)
    envsubst "$env_vars" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
    envsubst "$env_vars" < /etc/nginx/proxy.conf.template > /etc/nginx/proxy.conf
    
    # Check if SSL certificates exist
    if [ "${NGINX_HTTPS_ENABLED}" = "true" ] && [ -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} ] && [ -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} ]; then
        echo "SSL certificates found. Enabling HTTPS configuration."
        export NGINX_USE_HTTPS=true
        export NGINX_USE_HTTPS_COMMENT=""
    else
        echo "SSL certificates not found or HTTPS not enabled. Using HTTP-only configuration."
        export NGINX_USE_HTTPS=false
        export NGINX_USE_HTTPS_COMMENT="#"
    fi
    
    # Generate the configuration with the NGINX_USE_HTTPS variable
    envsubst "$env_vars" < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
}

# Generate initial config
generate_nginx_config

# Start Nginx
nginx -g 'daemon off;' &
NGINX_PID=$!

# Monitor for SSL certificates if HTTPS is enabled
if [ "${NGINX_HTTPS_ENABLED}" = "true" ] && [ "${NGINX_USE_HTTPS}" = "false" ]; then
    echo "Monitoring for SSL certificates at /etc/letsencrypt/live/${CERTBOT_DOMAIN}/"
    
    while true; do
        if [ -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} ] && [ -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} ]; then
            echo "SSL certificates found! Regenerating Nginx configuration with HTTPS..."
            export NGINX_USE_HTTPS=true
            export NGINX_USE_HTTPS_COMMENT=""
            generate_nginx_config
            nginx -s reload
            echo "Nginx reloaded with HTTPS configuration."
            break
        fi
        sleep 10
    done
fi

# Wait for Nginx to exit
wait $NGINX_PID