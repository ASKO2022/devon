#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon stop – stoppt die Container des aktuellen Projekts
# -------------------------------------------------------------------

stop() {
  echo "🛑 Stoppe Projekt-Container ..."
  docker compose -f "$MYDEV_DIR/docker-compose.yaml" down
  echo "✅ Projekt gestoppt."
}
