#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon logs – zeigt Logs von Django-, DB- oder Traefik-Containern
# -------------------------------------------------------------------

logs() {
  local TARGET="${1:-}"
  local DJ_CONTAINER="${PROJECT}-django"
  local DB_CONTAINER="${PROJECT}-db"

  case "$TARGET" in
    django)
      if docker ps -a --format '{{.Names}}' | grep -q "^${DJ_CONTAINER}$"; then
        echo "📜 Zeige Logs von ${DJ_CONTAINER} ..."
        docker logs -f "$DJ_CONTAINER"
      else
        echo "❌ Kein Container '${DJ_CONTAINER}' gefunden."
      fi
      ;;
    db)
      if docker ps -a --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
        echo "📜 Zeige Logs von ${DB_CONTAINER} ..."
        docker logs -f "$DB_CONTAINER"
      else
        echo "❌ Kein Container '${DB_CONTAINER}' gefunden."
      fi
      ;;
    traefik)
      if docker ps -a --format '{{.Names}}' | grep -q "^devon-traefik$"; then
        echo "📜 Zeige Traefik-Logs ..."
        docker logs -f devon-traefik
      else
        echo "⚠️  Traefik läuft nicht. Starte mit: devon router start"
      fi
      ;;
    "")
      echo "ℹ️  Nutzung: devon logs [django|db|traefik]"
      echo "Beispiele:"
      echo "  devon logs django"
      echo "  devon logs db"
      echo "  devon logs traefik"
      ;;
    *)
      echo "❌ Unbekannter Log-Typ: '$TARGET'"
      echo "Verfügbare Optionen: django | db | traefik"
      ;;
  esac
}
