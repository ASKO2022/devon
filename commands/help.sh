#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon help – zeigt Befehlsübersicht und Dokumentation
# -------------------------------------------------------------------

help() {
  cat <<'EOF'
devon – lokale Dev-Tooling CLI
───────────────────────────────────────────────────────────────

USAGE:
  devon <command> [options]

KOMMANDOS:
  config            Generiert/aktualisiert .devon/ inkl. Services & docker-compose.yaml
  start             Startet Projekt-Container (Django + DB + Traefik)
  stop              Stoppt Projekt-Container
  restart           Stoppt und startet das Projekt neu
  ssh               Öffnet eine Shell im Django-Container
  create            Führt framework-spezifische create.sh aus, erzeugt Config, startet
  delete            Entfernt Container, Volumes (-v) und .devon Ordner
  list              Listet vorhandene devon-Projekte (Container/Volumes/URL)
  status            Zeigt Status der relevanten Container + Projekt-URL
  logs [svc]        Zeigt Logs (svc: django|db|traefik)
  router <cmd>      Steuert globalen Traefik (start|stop|restart|logs)
  db <subcmd>       DB-Helfer: shell | import <dump.sql> | export [out.sql]
  open              Öffnet https://<project>.<domain-base> im Browser
  doctor            Diagnose: Docker/Compose/mkcert/Traefik & TLS-Check
  cert-reload       Hinweis zu automatischer Traefik-Konfig-Neuladung
  --version|-v      Zeigt devon CLI Version
  help|-h|--help    Diese Hilfe

BEISPIELE:
  devon config --type=django
  devon start
  devon logs django
  devon db shell
EOF
}

# Alias, damit print_help weiter funktioniert
print_help() { help "$@"; }
