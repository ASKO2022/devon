#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon ssh – öffnet eine Shell im Django-Container des Projekts
# -------------------------------------------------------------------

ssh() {
  local CONTAINER="${PROJECT}-django"

  echo "🔗 Öffne Shell in Container: $CONTAINER ..."
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    docker exec -it "$CONTAINER" bash
  else
    echo "❌ Container $CONTAINER läuft nicht."
    echo "Tipp: Starte ihn mit 'devon start'"
  fi
}
