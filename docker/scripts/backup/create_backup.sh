#!/bin/sh

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="docker/volumes/backups"
BACKUP_FILE="${BACKUP_DIR}/dify_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

echo "Starting backup creation..."

# Find the PostgreSQL container by its image name
DB_CONTAINER=$(docker ps --filter "ancestor=postgres:15-alpine" --format "{{.Names}}")

if [ -z "$DB_CONTAINER" ]; then
    echo "❌ Error: Could not find the PostgreSQL container. Please make sure it's running."
    echo "Try running: docker ps | grep postgres"
    exit 1
fi

echo "📦 Found database container: ${DB_CONTAINER}"

# Create the backup
echo "🔄 Creating backup..."
if docker exec ${DB_CONTAINER} pg_dump -U postgres dify > ${BACKUP_FILE}; then
    # Get backup size
    BACKUP_SIZE=$(ls -lh ${BACKUP_FILE} | awk '{print $5}')
    echo "✅ Backup created successfully!"
    echo "📁 Backup file: ${BACKUP_FILE}"
    echo "📊 Backup size: ${BACKUP_SIZE}"
    
    # Verify backup content
    echo "🔍 Verifying backup content..."
    if grep -q "PostgreSQL database dump complete" ${BACKUP_FILE}; then
        echo "✅ Backup verification successful"
    else
        echo "⚠️ Backup file created but verification incomplete"
    fi
else
    echo "❌ Backup failed! Error code: $?"
    exit 1
fi