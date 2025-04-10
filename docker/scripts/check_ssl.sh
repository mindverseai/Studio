#!/bin/sh

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if the certbot container is running
CERTBOT_STATUS=$(docker ps --filter "name=docker-certbot-1" --format "{{.Status}}")
if [ -z "$CERTBOT_STATUS" ]; then
    log "ERROR: Certbot container is not running"
    exit 1
fi

# Check if the certbot container is restarting
if echo "$CERTBOT_STATUS" | grep -q "Restarting"; then
    log "WARNING: Certbot container is restarting. This might be due to a renewal attempt."
    log "Please wait a moment and check again."
    exit 0
fi

# Try to find the .env file in both possible locations
if [ -f "/root/Studio/docker/.env" ]; then
    ENV_FILE="/root/Studio/docker/.env"
elif [ -f "/root/Mindverse-Studio/docker/.env" ]; then
    ENV_FILE="/root/Mindverse-Studio/docker/.env"
else
    log "ERROR: Could not find .env file in either /root/Studio/docker/ or /root/Mindverse-Studio/docker/"
    exit 1
fi

# Get the domain from the environment
DOMAIN=$(grep -o 'DOMAIN=.*' "$ENV_FILE" | cut -d'=' -f2)
if [ -z "$DOMAIN" ]; then
    log "ERROR: DOMAIN not found in $ENV_FILE"
    exit 1
fi

log "Checking SSL certificate for $DOMAIN"

# Check the certificate expiry date
EXPIRY_DATE=$(docker exec docker-certbot-1 certbot certificates | grep "Expiry Date" | awk '{print $3, $4}')
if [ -z "$EXPIRY_DATE" ]; then
    log "ERROR: Could not retrieve certificate expiry date"
    exit 1
fi

log "Certificate expiry date: $EXPIRY_DATE"

# Check the renewal configuration
RENEWAL_CONFIG=$(docker exec docker-certbot-1 certbot renew --dry-run)
if echo "$RENEWAL_CONFIG" | grep -q "Cert not due for renewal"; then
    log "Certificate is not due for renewal"
elif echo "$RENEWAL_CONFIG" | grep -q "Simulating renewal"; then
    log "Certificate renewal simulation successful"
else
    log "WARNING: Certificate renewal simulation failed"
    log "Renewal configuration:"
    echo "$RENEWAL_CONFIG"
fi

# Check if the cron daemon is running in the certbot container
CRON_STATUS=$(docker exec docker-certbot-1 ps aux | grep -v grep | grep crond)
if [ -z "$CRON_STATUS" ]; then
    log "WARNING: Cron daemon is not running in the certbot container"
    log "This might affect automatic certificate renewal"
else
    log "Cron daemon is running in the certbot container"
fi

# Check the cron job for certificate renewal
CRON_JOB=$(docker exec docker-certbot-1 crontab -l | grep "certbot renew")
if [ -z "$CRON_JOB" ]; then
    log "WARNING: No cron job found for certificate renewal"
    log "Please check the certbot container logs for more information"
else
    log "Cron job for certificate renewal is configured:"
    echo "$CRON_JOB"
fi

log "SSL certificate check completed"
log "Note: Certbot will attempt to renew the certificate automatically when it's close to expiry"
log "You can manually renew the certificate by running: docker exec docker-certbot-1 certbot renew"
log "To restart the certbot container: docker restart docker-certbot-1" 