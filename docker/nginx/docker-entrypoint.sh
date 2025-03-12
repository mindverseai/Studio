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
        # Use the HTTPS template
        envsubst "$env_vars" < /etc/nginx/conf.d/default-https.conf.template > /etc/nginx/conf.d/default.conf
    else
        echo "SSL certificates not found or HTTPS not enabled. Using HTTP-only configuration."
        export NGINX_USE_HTTPS=false
        # Use the HTTP-only template
        envsubst "$env_vars" < /etc/nginx/conf.d/default-http.conf.template > /etc/nginx/conf.d/default.conf
    fi
}

# Create HTTP-only template
cat > /etc/nginx/conf.d/default-http.conf.template << 'EOF'
# Please do not directly edit this file. Instead, modify the .env variables related to NGINX configuration.

# HTTP server for all traffic and Certbot validation
server {
    listen ${NGINX_PORT};
    server_name ${NGINX_SERVER_NAME};

    # Root directory for serving files
    root /var/www/html;

    # ACME Challenge Location for SSL certification
    location /.well-known/acme-challenge/ { 
        allow all;
        try_files $uri =404;
    }

    # Serve the application directly
    location / {
        proxy_pass http://web:3000;
        include /etc/nginx/proxy.conf;
    }

    location /console/api {
        proxy_pass http://api:5001;
        include /etc/nginx/proxy.conf;
    }

    location /api {
        proxy_pass http://api:5001;
        include /etc/nginx/proxy.conf;
    }

    location /v1 {
        proxy_pass http://api:5001;
        include /etc/nginx/proxy.conf;
    }

    location /files {
        proxy_pass http://api:5001;
        include /etc/nginx/proxy.conf;
    }

    location /explore {
        proxy_pass http://web:3000;
        include /etc/nginx/proxy.conf;
    }
}
EOF

# Create HTTPS template
cat > /etc/nginx/conf.d/default-https.conf.template << 'EOF'
# Please do not directly edit this file. Instead, modify the .env variables related to NGINX configuration.

# HTTP server for Certbot validation and redirects to HTTPS
server {
    listen ${NGINX_PORT};
    server_name ${NGINX_SERVER_NAME};

    # Root directory for serving files
    root /var/www/html;

    # ACME Challenge Location for SSL certification
    location /.well-known/acme-challenge/ { 
        allow all;
        try_files $uri =404;
    }

    # Redirect all HTTP traffic to HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server
server {
    listen ${NGINX_SSL_PORT} ssl;
    server_name ${NGINX_SERVER_NAME};

    # SSL certificates
    ssl_certificate_key /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME};
    ssl_certificate /etc/letsencrypt/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME};
    ssl_protocols ${NGINX_SSL_PROTOCOLS};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};
    proxy_read_timeout ${NGINX_PROXY_READ_TIMEOUT};
    proxy_send_timeout ${NGINX_PROXY_SEND_TIMEOUT};

    location /console/api {
      proxy_pass http://api:5001;
      include /etc/nginx/proxy.conf;
    }

    location /api {
      proxy_pass http://api:5001;
      include /etc/nginx/proxy.conf;
    }

    location /v1 {
      proxy_pass http://api:5001;
      include /etc/nginx/proxy.conf;
    }

    location /files {
      proxy_pass http://api:5001;
      include /etc/nginx/proxy.conf;
    }

    location /explore {
      proxy_pass http://web:3000;
      include /etc/nginx/proxy.conf;
    }

    # Nur aktivieren, wenn der Plugin-Daemon-Service läuft
    # location /e/ {
    #   proxy_pass http://plugin_daemon:5002;
    #   proxy_set_header Dify-Hook-Url $scheme://$host$request_uri;
    #   include /etc/nginx/proxy.conf;
    # }

    location / {
      proxy_pass http://web:3000;
      include /etc/nginx/proxy.conf;
    }
}
EOF

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