#!/bin/bash
set -e

# Function to generate Nginx configuration
generate_nginx_config() {
    # Process templates
    env_vars=$(printenv | cut -d= -f1 | sed 's/^/$/g' | paste -sd, -)
    envsubst "$env_vars" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
    envsubst "$env_vars" < /etc/nginx/proxy.conf.template > /etc/nginx/proxy.conf
    envsubst "$env_vars" < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
}

# Check if SSL certificates exist
check_ssl_certificates() {
    if [ "${NGINX_HTTPS_ENABLED}" = "true" ]; then
        if [ ! -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} ] || [ ! -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} ]; then
            echo "Warning: HTTPS is enabled but SSL certificates not found. Nginx will start with HTTP only until certificates are available."
            echo "Waiting for certificates to be generated at /etc/letsencrypt/live/${CERTBOT_DOMAIN}/"
            # Create a temporary SSL certificate to allow Nginx to start
            mkdir -p /etc/nginx/ssl/
            openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
                -keyout /etc/nginx/ssl/temp.key \
                -out /etc/nginx/ssl/temp.crt \
                -subj "/CN=localhost" 2>/dev/null
            
            # Create a temporary config that uses the temporary certificates
            sed -i "s|/etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME}|/etc/nginx/ssl/temp.key|g" /etc/nginx/conf.d/default.conf
            sed -i "s|/etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME}|/etc/nginx/ssl/temp.crt|g" /etc/nginx/conf.d/default.conf
            return 1
        else
            echo "SSL certificates found. HTTPS is fully enabled."
            return 0
        fi
    else
        echo "HTTPS is disabled. Running with HTTP only."
        return 0
    fi
}

# Generate initial config
generate_nginx_config

# Check SSL certificates
check_ssl_certificates
certificates_ready=$?

# Start Nginx
nginx -g 'daemon off;' &
nginx_pid=$!

# Wait for SSL certificates if HTTPS is enabled
if [ "${NGINX_HTTPS_ENABLED}" = "true" ] && [ $certificates_ready -eq 1 ]; then
    while [ ! -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} ] || [ ! -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} ]; do
        echo "Waiting for SSL certificates..."
        sleep 5
    done

    echo "SSL certificates found. Regenerating config and reloading Nginx."
    # Regenerate config with real SSL certificates
    generate_nginx_config

    # Reload Nginx
    nginx -s reload
fi

# Keep the script running
wait $nginx_pid