#!/bin/bash

# Stop the development web container
docker-compose -f docker-compose.dev.yaml stop web-dev

# Start the production web container
docker-compose up -d web

echo "Switched to production mode. The web frontend is now running in production mode." 