#!/bin/bash

# Automatisches Skript zur Erneuerung von Let's Encrypt-Zertifikaten
# Dieses Skript wird regelmäßig ausgeführt, um Zertifikate zu erneuern und Fehler zu behandeln

# Logging-Funktion
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /var/log/letsencrypt/auto-renew.log
}

log "Starte automatische Zertifikatserneuerung"

# Versuche, das Zertifikat zu erneuern
certbot renew --quiet

# Prüfe den Exit-Code
if [ $? -ne 0 ]; then
  log "Fehler bei der Erneuerung. Versuche, ein neues Zertifikat zu erstellen."
  
  # Versuche, ein neues Zertifikat zu erstellen
  certbot certonly --webroot --webroot-path=/var/www/html \
    --domain $CERTBOT_DOMAIN \
    --email $CERTBOT_EMAIL \
    --agree-tos --non-interactive \
    --force-renewal
  
  if [ $? -ne 0 ]; then
    log "Fehler beim Erstellen eines neuen Zertifikats. Versuche mit --staging Option."
    
    # Versuche mit Staging-Option (um Rate-Limits zu vermeiden)
    certbot certonly --webroot --webroot-path=/var/www/html \
      --domain $CERTBOT_DOMAIN \
      --email $CERTBOT_EMAIL \
      --agree-tos --non-interactive \
      --staging
      
    if [ $? -eq 0 ]; then
      log "Staging-Zertifikat erfolgreich erstellt. Versuche jetzt ein Produktionszertifikat."
      
      # Wenn Staging erfolgreich war, versuche ein Produktionszertifikat
      certbot certonly --webroot --webroot-path=/var/www/html \
        --domain $CERTBOT_DOMAIN \
        --email $CERTBOT_EMAIL \
        --agree-tos --non-interactive \
        --force-renewal
    else
      log "Auch Staging-Zertifikat konnte nicht erstellt werden. Bitte manuell überprüfen."
    fi
  else
    log "Neues Zertifikat erfolgreich erstellt."
  fi
else
  log "Zertifikat erfolgreich erneuert."
fi

# Nginx neu starten, um die neuen Zertifikate zu laden
log "Starte Nginx neu..."
nginx -s reload || log "Fehler beim Neustarten von Nginx"

log "Automatische Zertifikatserneuerung abgeschlossen" 