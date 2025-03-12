#!/bin/bash

# Skript zur Erstellung von selbstsignierten Zertifikaten für die lokale Entwicklung

# Logging-Funktion
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /Users/jack/Documents/GitHub/Studio/docker/create-certs.log
}

log "Starte Zertifikatserstellung"

# Wechsle in das Docker-Verzeichnis
cd /Users/jack/Documents/GitHub/Studio/docker

# Lade Umgebungsvariablen
if [ -f .env ]; then
  source .env
  log "Umgebungsvariablen aus .env geladen."
else
  log "Keine .env-Datei gefunden. Verwende Standardwerte."
  CERTBOT_DOMAIN="flexable-studio.mind-verse.de"
  NGINX_SSL_CERT_FILENAME="fullchain.pem"
  NGINX_SSL_CERT_KEY_FILENAME="privkey.pem"
fi

# Erstelle Verzeichnisse
mkdir -p ./volumes/certbot/conf/live/${CERTBOT_DOMAIN}
log "Verzeichnisse erstellt."

# Prüfe, ob Zertifikate bereits existieren
if [ -f ./volumes/certbot/conf/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} ] && [ -f ./volumes/certbot/conf/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} ]; then
  log "Zertifikate existieren bereits."
else
  log "Erstelle selbstsignierte Zertifikate für die lokale Entwicklung..."
  
  # Erstelle selbstsignierte Zertifikate
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./volumes/certbot/conf/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME} \
    -out ./volumes/certbot/conf/live/${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME} \
    -subj "/CN=${CERTBOT_DOMAIN}" \
    -addext "subjectAltName=DNS:${CERTBOT_DOMAIN}"
  
  if [ $? -eq 0 ]; then
    log "Selbstsignierte Zertifikate erfolgreich erstellt."
  else
    log "Fehler bei der Erstellung der selbstsignierten Zertifikate."
    exit 1
  fi
fi

# Setze Berechtigungen
chmod -R 755 ./volumes/certbot/conf
log "Berechtigungen gesetzt."

# Starte Nginx neu
log "Starte Nginx neu..."
docker-compose restart nginx
log "Nginx neu gestartet."

log "Zertifikatserstellung abgeschlossen" 