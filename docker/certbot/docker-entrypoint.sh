#!/bin/sh
set -e

# Create required directories
mkdir -p /var/www/html
mkdir -p /etc/letsencrypt

# Function to check if certificate exists and is valid
check_certificate() {
    if [ -d "/etc/letsencrypt/live/${CERTBOT_DOMAIN}" ]; then
        # Check if certificate is valid (not expired)
        if ! openssl x509 -noout -dates -in "/etc/letsencrypt/live/${CERTBOT_DOMAIN}/fullchain.pem" | grep -q "notAfter"; then
            return 1
        fi
        return 0
    fi
    return 1
}

# Function to obtain certificate
obtain_certificate() {
    certbot certonly --webroot \
        --webroot-path=/var/www/html \
        --email "${CERTBOT_EMAIL}" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        --non-interactive \
        --domain "${CERTBOT_DOMAIN}" \
        ${CERTBOT_OPTIONS}
}

# Main logic
if ! check_certificate; then
    echo "No valid certificate found. Obtaining new certificate..."
    obtain_certificate
else
    echo "Valid certificate found."
fi

# Keep container running
exec "$@"
