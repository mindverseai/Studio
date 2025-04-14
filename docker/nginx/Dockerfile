FROM nginx:latest

# Install envsubst
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /docker-entrypoint.d/conf.d

# Copy configuration templates
COPY conf.d/default.conf.template /docker-entrypoint.d/conf.d/
COPY conf.d/https.conf.template /docker-entrypoint.d/conf.d/
COPY nginx.conf.template /docker-entrypoint.d/
COPY proxy.conf.template /docker-entrypoint.d/

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"] 