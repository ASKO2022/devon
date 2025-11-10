#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon list – listet alle devon-Projekte mit Containerstatus, Domain & Volume
# -------------------------------------------------------------------

list() {
  echo "📦 devon Projekte:"
  echo ""

  # Suche alle devon-Django-Container (auch gestoppte)
  local CONTAINERS
  CONTAINERS=$(docker ps -a --format '{{.Names}}' | grep -E '.*-django$' || true)

  if [ -z "$CONTAINERS" ]; then
    echo "⚠️  Keine devon Projekte gefunden."
    return 0
  fi

  for django in $CONTAINERS; do
    local PROJECT_NAME DB_CONTAINER DJANGO_STATUS DB_STATUS PORT DOMAIN_VAL VOLUME

    PROJECT_NAME=$(echo "$django" | sed 's/-django$//')
    DB_CONTAINER="${PROJECT_NAME}-db"

    # Status abfragen
    DJANGO_STATUS=$(docker inspect -f '{{.State.Status}}' "$django" 2>/dev/null || echo "nicht vorhanden")
    DB_STATUS=$(docker inspect -f '{{.State.Status}}' "$DB_CONTAINER" 2>/dev/null || echo "nicht vorhanden")

    # Port (lokaler Fallback, wenn kein Traefik läuft)
    PORT=$(docker port "$django" 2>/dev/null | head -n 1 | awk -F: '{print $2}')

    # Domain aus config.yaml
    DOMAIN_VAL=""
    if [ -f "$PROJECT_NAME/.devon/config.yaml" ]; then
      DOMAIN_VAL=$(grep '^domain:' "$PROJECT_NAME/.devon/config.yaml" | awk '{print $2}')
    elif [ -f ".devon/config.yaml" ]; then
      DOMAIN_VAL=$(grep '^domain:' ".devon/config.yaml" | awk '{print $2}')
    fi

    # Volume suchen
    VOLUME=$(docker inspect -f '{{range .Mounts}}{{.Name}}{{end}}' "$DB_CONTAINER" 2>/dev/null || true)

    echo "🔹 $PROJECT_NAME"
    echo "   Django:    $DJANGO_STATUS"
    echo "   Datenbank: $DB_STATUS"

    # URL bestimmen
    if [ -n "$PORT" ]; then
      echo "   URL:       http://localhost:$PORT"
    elif docker ps | grep -q devon-traefik && [ -n "$DOMAIN_VAL" ]; then
      echo "   URL:       https://$DOMAIN_VAL"
    else
      echo "   URL:       (nicht aktiv)"
    fi

    # Volume ausgeben
    if [ -n "$VOLUME" ]; then
      echo "   Volume:    $VOLUME"
    else
      echo "   Volume:    (nicht gefunden)"
    fi

    echo ""
  done
}
