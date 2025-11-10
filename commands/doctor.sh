#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon doctor – prüft Systemumgebung, Docker, Traefik und Zertifikate
# -------------------------------------------------------------------

doctor() {
  echo "🩺 devon doctor"
  echo "──────────────────────────────────────────────"

  # ---- System-Basischecks ----
  echo "🔧 Basis-Checks:"

  if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker fehlt (installiere es über Docker Desktop oder brew install docker)"
    return 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose v2 fehlt (prüfe docker compose plugin)"
    return 1
  fi

  if command -v mkcert >/dev/null 2>&1; then
    echo "✅ mkcert ist installiert"
  else
    echo "❌ mkcert fehlt (installiere mit: brew install mkcert nss && mkcert -install)"
  fi

  if command -v yq >/dev/null 2>&1; then
    echo "✅ yq ist installiert"
  else
    echo "⚠️  yq nicht gefunden (wird empfohlen; Fallback via grep/awk aktiv)"
  fi

  echo "──────────────────────────────────────────────"

  # ---- Traefik Check ----
  echo "🌍 Traefik-Router:"
  if docker ps --format '{{.Names}}' | grep -q '^devon-traefik$'; then
    echo "✅ Traefik läuft"
  else
    echo "⚠️  Traefik läuft nicht. Starte mit: devon router start"
  fi

  echo "──────────────────────────────────────────────"

  # ---- Projekt & Domain ----
  load_env_or_cfg
  local DOMAIN="${DOMAIN:-${PROJECT}.${DOMAIN_BASE}}"

  echo "📜 Projektinformationen:"
  echo "   🔹 Projekt: $PROJECT"
  echo "   🔗 Domain:  https://${DOMAIN}"
  echo "──────────────────────────────────────────────"

  # ---- Zertifikat ----
  echo "🔒 TLS-Zertifikatstest:"
  if command -v openssl >/dev/null 2>&1; then
    local SUBJECT
    SUBJECT=$(echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null \
      | openssl x509 -noout -subject 2>/dev/null || true)

    if [ -n "$SUBJECT" ]; then
      echo "✅ Zertifikat aktiv:"
      echo "   $SUBJECT"
    else
      echo "⚠️  Kein gültiges Zertifikat gefunden (mkcert evtl. neu ausführen)"
    fi
  else
    echo "⚠️  openssl nicht installiert → kann Zertifikat nicht prüfen"
  fi

  echo "──────────────────────────────────────────────"

  # ---- Netzwerk ----
  echo "🔌 Docker-Netzwerk:"
  if docker network inspect devon >/dev/null 2>&1; then
    echo "✅ devon-Netzwerk existiert"
  else
    echo "⚠️  devon-Netzwerk fehlt → wird automatisch bei Start erstellt"
  fi

  echo "──────────────────────────────────────────────"
  echo "✅ Doctor abgeschlossen"
}
