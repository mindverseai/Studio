#!/bin/bash

# Skript zum Neuladen der Nginx-Konfiguration und Neustart des Containers

# Logging-Funktion
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /Users/jack/Documents/GitHub/Studio/docker/nginx-reload.log
}

log "Starte Neuladen der Nginx-Konfiguration"

# Wechsle in das Docker-Verzeichnis
cd /Users/jack/Documents/GitHub/Studio/docker

# Kopiere die Template-Datei
log "Kopiere die Template-Datei..."
cp nginx/conf.d/default.conf.template nginx/conf.d/default.conf.template.bak
log "Template-Datei gesichert."

# Starte Nginx neu
log "Starte Nginx neu..."
docker-compose restart nginx
log "Nginx neu gestartet."

# Prüfe den Status von Nginx
log "Prüfe den Status von Nginx..."
docker-compose ps nginx
log "Nginx-Status geprüft."

log "Neuladen der Nginx-Konfiguration abgeschlossen" 