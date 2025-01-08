#!/bin/sh
set -e

printf '%s\n' "Docker entrypoint script is running"

validate_env_vars() {
    for var in CERTBOT_EMAIL CERTBOT_DOMAIN; do
        eval value=\$$var
        if [ -z "$value" ]; then
            printf '%s\n' "Error: $var is not set" >&2
            exit 1
        fi
    done
}

validate_env_vars

printf '%s\n' "\nChecking specific environment variables:"
printf '%s\n' "CERTBOT_EMAIL: ${CERTBOT_EMAIL}"
printf '%s\n' "CERTBOT_DOMAIN: ${CERTBOT_DOMAIN}"
printf '%s\n' "CERTBOT_OPTIONS: ${CERTBOT_OPTIONS:-Not set}"

printf '%s\n' "\nChecking mounted directories:"
for dir in "/etc/letsencrypt" "/var/www/html" "/var/log/letsencrypt"; do
    if [ -d "$dir" ]; then
        printf '%s\n' "$dir exists. Contents:"
        ls -la "$dir"
    else
        printf '%s\n' "$dir does not exist."
        mkdir -p "$dir"
        printf '%s\n' "Created $dir"
    fi
done

printf '%s\n' "\nGenerating update-cert.sh from template"
sed -e "s|\${CERTBOT_EMAIL}|$CERTBOT_EMAIL|g" \
    -e "s|\${CERTBOT_DOMAIN}|$CERTBOT_DOMAIN|g" \
    -e "s|\${CERTBOT_OPTIONS}|$CERTBOT_OPTIONS|g" \
    /update-cert.template.txt > /update-cert.sh

chmod +x /update-cert.sh

obtain_or_renew_cert() {
    certbot certonly --webroot --webroot-path /var/www/html \
        -d "$CERTBOT_DOMAIN" \
        -m "$CERTBOT_EMAIL" \
        --agree-tos \
        --no-eff-email \
        $CERTBOT_OPTIONS
}

if [ -d "/etc/letsencrypt/live/$CERTBOT_DOMAIN" ]; then
    printf '%s\n' "\nCertificates for $CERTBOT_DOMAIN already exist. Attempting renewal."
    obtain_or_renew_cert --force-renewal
else
    printf '%s\n' "\nObtaining initial certificate for $CERTBOT_DOMAIN"
    obtain_or_renew_cert
fi

printf '%s\n' "\nSetting up certificate renewal cron job"
echo "0 */12 * * * /update-cert.sh" | crontab -

# Start crond in the background
crond

trap 'echo "Stopping container..."; kill $(jobs -p)' SIGTERM

if [ $# -eq 0 ]; then
    printf '%s\n' "\nNo additional command provided. Waiting indefinitely."
    while true; do
        sleep 86400 & wait $!
    done
else
    printf '%s\n' "\nExecuting additional command:" "$@"
    exec "$@"
fi