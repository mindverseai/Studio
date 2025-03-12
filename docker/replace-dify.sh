#!/bin/bash

# Dieses Skript ersetzt alle Vorkommen von "Dify" durch "Mindverse" in den Übersetzungsdateien

# Führe das Skript im Web-Container aus
docker exec -it docker-web-1 /bin/sh -c "find /app/web/i18n -type f -name '*.ts' -exec sed -i 's/Dify/Mindverse/g' {} \;"

echo "Alle Vorkommen von 'Dify' wurden durch 'Mindverse' ersetzt." 