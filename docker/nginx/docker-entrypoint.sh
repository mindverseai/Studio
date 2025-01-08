#!/bin/bash

# Function to generate Nginx configuration
generate_nginx_config() {
    # Initialize variables
    HTTPS_REDIRECT=''
    HTTPS_SERVER=''

    if [ "${NGINX_HTTPS_ENABLED}" = "true" ]; then
        SSL_CERTIFICATE_PATH="/etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME}"
        SSL_CERTIFICATE_KEY_PATH="/etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME}"

        export SSL_CERTIFICATE_PATH
        export SSL_CERTIFICATE_KEY_PATH

        # Set up HTTPS redirect
        HTTPS_REDIRECT='return 301 https://$server_name$request_uri;'

        # Create HTTPS server block
        HTTPS_SERVER=$(
            cat <<EOF
server {
    listen ${NGINX_SSL_PORT} ssl;
    server_name ${NGINX_SERVER_NAME};

    ssl_certificate ${SSL_CERTIFICATE_PATH};
    ssl_certificate_key ${SSL_CERTIFICATE_KEY_PATH};
    ssl_protocols ${NGINX_SSL_PROTOCOLS};
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location /console/api {
        proxy_pass http://api:5001;
        include proxy.conf;
    }

    location /api {
        proxy_pass http://api:5001;
        include proxy.conf;
    }

    location /v1 {
        proxy_pass http://api:5001;
        include proxy.conf;
    }

    location /files {
        proxy_pass http://api:5001;
        include proxy.conf;
    }

    location / {
        proxy_pass http://web:3000;
        include proxy.conf;
    }
}
EOF
        )
    fi

    export HTTPS_REDIRECT
    export HTTPS_SERVER

    if [ "${NGINX_ENABLE_CERTBOT_CHALLENGE}" = "true" ]; then
        ACME_CHALLENGE_LOCATION='location /.well-known/acme-challenge/ { root /var/www/certbot; }'
    else
        ACME_CHALLENGE_LOCATION=''
    fi
    export ACME_CHALLENGE_LOCATION

    # Process templates
    env_vars=$(printenv | cut -d= -f1 | sed 's/^/$/g' | paste -sd, -)
    envsubst "$env_vars" </etc/nginx/nginx.conf.template >/etc/nginx/nginx.conf
    envsubst "$env_vars" </etc/nginx/proxy.conf.template >/etc/nginx/proxy.conf
    envsubst "$env_vars" </etc/nginx/conf.d/default.conf.template >/etc/nginx/conf.d/default.conf
}

# Generate initial config without SSL
NGINX_HTTPS_ENABLED=false
generate_nginx_config

# Start Nginx
nginx

# Wait for SSL certificates if HTTPS is enabled
if [ "${NGINX_HTTPS_ENABLED}" = "true" ]; then
    while [ ! -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} ] || [ ! -f /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} ]; do
        echo "Waiting for SSL certificates..."
        sleep 5
    done

    # Generate full config with SSL
    NGINX_HTTPS_ENABLED=true
    generate_nginx_config

    # Reload Nginx
    nginx -s reload
fi

# Keep the script running
tail -f /dev/null
