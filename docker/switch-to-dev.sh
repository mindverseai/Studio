#!/bin/bash

# Stop the production web container
docker-compose stop web

# Start the development web container
docker-compose -f docker-compose.dev.yaml up -d web-dev

echo "Switched to development mode. The web frontend is now running in development mode at http://localhost:3000"
echo "Any changes you make to the web code will be automatically reflected." 