#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon router – steuert den globalen Traefik-Router (start|stop|restart|logs)
# -------------------------------------------------------------------

router() {
  local ACTION="${1:-}"
  local ROUTER_DIR="$DEVON_HOME/traefik"
  local COMPOSE_FILE="$ROUTER_DIR/docker-compose.yaml"

  if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Traefik docker-compose.yaml nicht gefunden unter: $COMPOSE_FILE"
    return 1
  fi

  case "$ACTION" in
    start)
      echo "🚀 Starte globalen Traefik-Router ..."
      docker compose -f "$COMPOSE_FILE" up -d
      ;;
    stop)
      echo "🛑 Stoppe globalen Traefik-Router ..."
      docker compose -f "$COMPOSE_FILE" down
      ;;
    restart)
      echo "🔁 Starte Traefik neu ..."
      docker compose -f "$COMPOSE_FILE" down
      docker compose -f "$COMPOSE_FILE" up -d
      ;;
    logs)
      echo "📜 Zeige Traefik-Logs ..."
      docker logs -f devon-traefik
      ;;
    status)
      echo "📊 Status des Traefik-Routers:"
      docker ps --filter "name=devon-traefik" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || true
      ;;
    *)
      echo "🧭 Router Befehle:"
      echo "  devon router start     - startet globalen Traefik"
      echo "  devon router stop      - stoppt ihn"
      echo "  devon router restart   - startet neu"
      echo "  devon router logs      - zeigt Logs"
      echo "  devon router status    - zeigt Status des Containers"
      ;;
  esac
}
