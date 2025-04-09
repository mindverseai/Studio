#!/bin/sh

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="docker/volumes/backups"
BACKUP_FILE="${BACKUP_DIR}/dify_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

echo "Starting backup creation..."

# Create the backup
docker exec docker_db_1 pg_dump -U postgres dify > ${BACKUP_FILE}

# Check if backup was successful
if [ $? -eq 0 ]; then
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
    echo "❌ Backup failed!"
    exit 1
fi