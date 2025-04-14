FROM nginx:1.25-alpine

# Create required directories
RUN mkdir -p /docker-entrypoint.d/conf.d \
    && mkdir -p /var/www/html \
    && mkdir -p /etc/letsencrypt

# Copy configuration files
COPY conf.d/default.conf.template /docker-entrypoint.d/conf.d/
COPY conf.d/https.conf.template /docker-entrypoint.d/conf.d/
COPY nginx.conf.template /docker-entrypoint.d/
COPY proxy.conf.template /docker-entrypoint.d/

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"] 