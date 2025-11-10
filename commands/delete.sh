#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon delete – entfernt Container, Volumes und .devon-Ordner des Projekts
# -------------------------------------------------------------------

delete() {
  echo "🗑️  Entferne Projekt: $PROJECT"
  echo "───────────────────────────────"

  # Sicherheitsabfrage (nur, wenn interaktiv)
  if [ -t 0 ]; then
    read -rp "⚠️  Bist du sicher, dass du das Projekt '$PROJECT' löschen willst? [y/N] " confirm
    case "$confirm" in
      [yY][eE][sS]|[yY]) ;;
      *) echo "❌ Abgebrochen."; return 1 ;;
    esac
  fi

  echo "🧹 Stoppe und entferne Container + Volumes ..."
  docker compose -f "$MYDEV_DIR/docker-compose.yaml" down -v --remove-orphans

  echo "📂 Entferne .devon-Ordner ..."
  rm -rf "$MYDEV_DIR"

  echo "✅ Projekt vollständig entfernt."
}
