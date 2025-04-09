#!/bin/bash

# Backup configuration
BACKUP_DIR="/root/backups/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="dify_backup_${TIMESTAMP}.sql"
LOG_FILE="/var/log/dify_backup.log"
RETENTION_DAYS=7

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

# Start backup process
log_message "Starting backup process..."

# Create backup
if docker exec docker_db_1 pg_dump -U postgres dify > "${BACKUP_DIR}/${BACKUP_FILE}"; then
    log_message "Database backup created successfully"
    
    # Compress backup
    if gzip "${BACKUP_DIR}/${BACKUP_FILE}"; then
        log_message "Backup compressed successfully"
        
        # Calculate backup size
        BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}.gz" | cut -f1)
        log_message "Backup size: ${BACKUP_SIZE}"
        
        # Clean old backups
        OLD_BACKUPS=$(find ${BACKUP_DIR} -name "dify_backup_*.sql.gz" -mtime +${RETENTION_DAYS})
        if [ ! -z "$OLD_BACKUPS" ]; then
            find ${BACKUP_DIR} -name "dify_backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
            log_message "Cleaned up backups older than ${RETENTION_DAYS} days"
        fi
        
        # Verify backup
        if gunzip -t "${BACKUP_DIR}/${BACKUP_FILE}.gz"; then
            log_message "Backup verification successful"
            log_message "Backup completed successfully: ${BACKUP_FILE}.gz"
            exit 0
        else
            log_message "ERROR: Backup verification failed"
            exit 1
        fi
    else
        log_message "ERROR: Failed to compress backup"
        exit 1
    fi
else
    log_message "ERROR: Failed to create database backup"
    exit 1
fi 