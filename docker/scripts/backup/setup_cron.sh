#!/bin/sh

# Make the backup script executable
chmod +x /root/backups/backup.sh

# Create log file if it doesn't exist
touch /var/log/dify_backup.log

# Add cron job if it doesn't exist
(crontab -l 2>/dev/null | grep -q "backup.sh") || \
    (echo "0 3 * * * /root/backups/backup.sh >> /var/log/dify_backup.log 2>&1" | crontab -)

# Run initial backup
/root/backups/backup.sh 