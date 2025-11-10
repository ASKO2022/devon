#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon status – zeigt den Status des aktuellen Projekts und Traefik an
# -------------------------------------------------------------------

status() {
  load_env_or_cfg
  local DOMAIN="${DOMAIN:-${PROJECT}.${DOMAIN_BASE}}"
  local DJ_CONTAINER="${PROJECT}-django"
  local DB_CONTAINER="${PROJECT}-db"

  echo "🔹 Projekt: $PROJECT"
  echo "───────────────────────────────"

  # Containerstatus-Tabelle (Django, DB und Traefik)
  docker ps -a \
    --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' |
    egrep "(^NAMES|${DJ_CONTAINER}$|${DB_CONTAINER}$|devon-traefik$)" || true

  echo "───────────────────────────────"
  echo "🌐 URL: https://${DOMAIN}"

  # Zusatz: Kurze Zusammenfassung
  echo ""
  if docker ps | grep -q "$DJ_CONTAINER"; then
    echo "✅ Django läuft"
  else
    echo "⚠️  Django-Container ist nicht aktiv"
  fi

  if docker ps | grep -q "$DB_CONTAINER"; then
    echo "✅ Datenbank läuft"
  else
    echo "⚠️  Datenbank-Container ist nicht aktiv"
  fi

  if docker ps | grep -q devon-traefik; then
    echo "✅ Traefik-Router läuft"
  else
    echo "⚠️  Traefik ist gestoppt – starte mit: devon router start"
  fi

  echo ""
}
