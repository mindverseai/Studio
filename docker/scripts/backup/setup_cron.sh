#!/bin/bash

# Make backup script executable
chmod +x /root/backups/backup.sh

# Create log file if it doesn't exist
touch /var/log/dify_backup.log

# Add cron job if it doesn't exist
CRON_JOB="0 3 * * * /root/backups/backup.sh >> /var/log/dify_backup.log 2>&1"
(crontab -l 2>/dev/null | grep -Fq "$CRON_JOB") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# Run initial backup
/root/backups/backup.sh

echo "Cron job has been set up successfully"
echo "Backup will run daily at 3:00 AM" 