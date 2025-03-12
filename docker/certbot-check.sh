#!/bin/bash

# Skript zur Überprüfung und automatischen Erneuerung von Let's Encrypt-Zertifikaten

# Logging-Funktion
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /Users/jack/Documents/GitHub/Studio/docker/certbot-check.log
}

log "Starte Zertifikatsprüfung"

# Prüfe, ob der Certbot-Container läuft
CERTBOT_RUNNING=$(docker ps -q -f name=docker-certbot-1)
if [ -z "$CERTBOT_RUNNING" ]; then
  log "Certbot-Container läuft nicht. Starte ihn neu..."
  cd /Users/jack/Documents/GitHub/Studio/docker
  docker-compose up -d certbot
  log "Certbot-Container neu gestartet."
else
  log "Certbot-Container läuft bereits."
fi

# Führe das Auto-Renew-Skript im Container aus
log "Führe Auto-Renew-Skript im Container aus..."
docker exec docker-certbot-1 /usr/local/bin/auto-renew.sh || {
  log "Fehler beim Ausführen des Auto-Renew-Skripts. Starte Certbot-Container neu..."
  cd /Users/jack/Documents/GitHub/Studio/docker
  docker-compose restart certbot
  log "Certbot-Container neu gestartet."
}

# Starte Nginx neu, um die neuen Zertifikate zu laden
log "Starte Nginx neu..."
docker-compose restart nginx
log "Nginx neu gestartet."

log "Zertifikatsprüfung abgeschlossen" 