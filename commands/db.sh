#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon db – Datenbank-Helfer (shell, import, export)
# -------------------------------------------------------------------

db() {
  load_env_or_cfg
  local DB_CONTAINER="${PROJECT}-db"
  local ACTION="${1:-}"
local FILE="${2:-}"

  case "$ACTION" in
    shell)
      echo "🐘 Öffne PostgreSQL-Shell im Container: $DB_CONTAINER"
      docker exec -it "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME"
      ;;
    import)
      if [ -z "$FILE" ]; then
        echo "❌ Bitte gib eine Datei an: devon db import <dump.sql>"
        return 1
      fi
      if [ ! -f "$FILE" ]; then
        echo "❌ Datei '$FILE' nicht gefunden."
        return 1
      fi
      echo "📥 Importiere SQL-Dump in $DB_NAME ..."
      cat "$FILE" | docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME"
      echo "✅ Import abgeschlossen."
      ;;
    export)
      local OUT="${FILE:-${PROJECT}_dump.sql}"
      echo "💾 Exportiere Datenbank $DB_NAME → $OUT ..."
      docker exec -i "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$OUT"
      echo "✅ Export gespeichert unter: $OUT"
      ;;
    *)
      echo "📘 Nutzung:"
      echo "  devon db shell             # öffnet psql-Shell"
      echo "  devon db import <dump.sql> # importiert SQL-Datei in Container"
      echo "  devon db export [out.sql]  # exportiert Datenbankdump"
      ;;
  esac
}
