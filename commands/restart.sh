#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon restart – stoppt und startet das aktuelle Projekt neu
# -------------------------------------------------------------------

restart() {
  echo "🔁 Starte Projekt $PROJECT neu ..."

  # 🔧 Lade stop/start-Funktionen, falls sie noch nicht im Kontext sind
  [ "$(type -t stop)" != "function" ] && source "$DEVON_HOME/commands/stop.sh"
  [ "$(type -t start)" != "function" ] && source "$DEVON_HOME/commands/start.sh"

  echo "🛑 Stoppe Container ..."
  stop

  echo "🚀 Starte Container ..."
  start

  echo "✅ Neustart abgeschlossen."
}
