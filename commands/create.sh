#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon create – erstellt ein neues Projekt auf Basis des Frameworks
# -------------------------------------------------------------------

create() {
  echo "🧩 Starte Projekterstellung ..."
  local CFG_FILE=".devon/config.yaml"

  if [ ! -f "$CFG_FILE" ]; then
    echo "❌ Keine Konfigurationsdatei gefunden ($CFG_FILE)"
    echo "💡 Tipp: erstelle sie mit: devon config --type=<framework>"
    return 1
  fi

  # Framework aus YAML lesen
  local FRAMEWORK
  FRAMEWORK=$(grep framework "$CFG_FILE" | awk '{print $2}')

  if [ -z "$FRAMEWORK" ]; then
    echo "❌ Framework konnte nicht ausgelesen werden."
    echo "💡 Füge 'framework: <name>' in $CFG_FILE hinzu."
    return 1
  fi

  local CREATE_SCRIPT="$TEMPLATES/frameworks/$FRAMEWORK/create.sh"

  if [ ! -f "$CREATE_SCRIPT" ]; then
    echo "❌ Kein create.sh für Framework '$FRAMEWORK' gefunden."
    echo "📂 Gesucht unter: $CREATE_SCRIPT"
    return 1
  fi

  echo "🚧 Erstelle Projekt mit Framework '$FRAMEWORK' ..."
  bash "$CREATE_SCRIPT"

  echo "🔧 Konfiguriere Projektdateien ..."
  devon config --type="$FRAMEWORK"

  echo "🚀 Starte lokale Container ..."
  devon start

  echo "🌐 Prüfe globalen Traefik-Router ..."
  if docker ps | grep -q devon-traefik; then
    echo "✅ Traefik läuft bereits."
  else
    echo "🌍 Starte globalen Traefik-Router ..."
    devon router start
  fi

  echo "✅ Projekt erfolgreich erstellt!"
}
