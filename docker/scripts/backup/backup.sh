#!/bin/sh

# Backup configuration
BACKUP_DIR="/root/backups/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/dify_backup_${TIMESTAMP}.sql"
LOG_FILE="/var/log/dify_backup.log"
RETENTION_DAYS=7

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Start backup process
log "Starting backup process..."

# Create backup using pg_dump
if pg_dump -h db -U postgres -d dify > "${BACKUP_FILE}"; then
    # Compress the backup
    gzip "${BACKUP_FILE}"
    
    # Calculate backup size
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
    
    # Clean up old backups
    find "${BACKUP_DIR}" -name "dify_backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
    
    # Log success
    log "Backup completed successfully. Size: ${BACKUP_SIZE}"
    log "Backup file: ${BACKUP_FILE}.gz"
    
    # Verify backup
    if gunzip -t "${BACKUP_FILE}.gz"; then
        log "Backup verification successful"
    else
        log "ERROR: Backup verification failed"
        exit 1
    fi
else
    log "ERROR: Backup failed"
    exit 1
fi 