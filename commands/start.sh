#!/usr/bin/env bash

# -------------------------------------------------------------------
# devon start – startet das aktuelle Projekt (Django + DB + Traefik)
# -------------------------------------------------------------------
start() {
  load_env_or_cfg
  DOMAIN="${DOMAIN:-${PROJECT}.${DOMAIN_BASE}}"
  GLOBAL_CERT_DIR="$DEVON_HOME/traefik/global_certs"
  mkdir -p "$GLOBAL_CERT_DIR"

  echo "🚀 Starte lokales devon Projekt: $PROJECT"
  echo "🌐 Domain: $DOMAIN"

  # 🔍 Prüfe mkcert Installation
  if ! command -v mkcert >/dev/null 2>&1; then
    echo "❌ mkcert fehlt. Bitte installiere mit:"
    echo "   brew install mkcert nss && mkcert -install"
    return 1
  fi

  # 🔒 SSL-Zertifikat erzeugen (nur falls nicht vorhanden)
  CRT="$GLOBAL_CERT_DIR/${DOMAIN}.crt"
  KEY="$GLOBAL_CERT_DIR/${DOMAIN}.key"
  YAML="$GLOBAL_CERT_DIR/${DOMAIN}.yaml"

  if [ ! -f "$CRT" ]; then
    echo "🔒 Erstelle SSL-Zertifikat für Domain: $DOMAIN ..."
    mkcert -cert-file "$CRT" -key-file "$KEY" "$DOMAIN"
  else
    echo "✅ Zertifikat bereits vorhanden: $CRT"
  fi

  # 🌎 YAML für Traefik erzeugen
  cat > "$YAML" <<EOF
tls:
  certificates:
    - certFile: /mnt/devon-global-cache/traefik/certs/${DOMAIN}.crt
      keyFile: /mnt/devon-global-cache/traefik/certs/${DOMAIN}.key
EOF

  # 📡 Zertifikate in Traefik-Container kopieren
  echo "📡 Kopiere Zertifikate in Traefik-Container ..."
  docker exec devon-traefik mkdir -p /mnt/devon-global-cache/traefik/certs 2>/dev/null || true
  docker cp "$CRT"  devon-traefik:/mnt/devon-global-cache/traefik/certs/
  docker cp "$KEY"  devon-traefik:/mnt/devon-global-cache/traefik/certs/
  docker cp "$YAML" devon-traefik:/mnt/devon-global-cache/traefik/certs/

  echo "✅ Zertifikat aktiv unter: /mnt/devon-global-cache/traefik/certs/${DOMAIN}.crt"

  # 🧩 Domain in /etc/hosts sicherstellen
  if ! grep -q "$DOMAIN" /etc/hosts; then
    echo "🧩 Füge Domain zu /etc/hosts hinzu: $DOMAIN"
    echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts >/dev/null
  else
    echo "✅ Domain bereits in /etc/hosts"
  fi

  # 🧭 Traefik läuft?
  if ! docker ps | grep -q devon-traefik; then
    echo "🌐 Starte globalen Traefik-Router ..."
    devon router start
  fi

  # 🐍 Django + DB starten
  echo "🐍 Starte Django + Datenbank ..."
  docker compose --env-file "$MYDEV_DIR/.env" -f "$MYDEV_DIR/docker-compose.yaml" up -d --remove-orphans

  echo ""
  echo "✅ Projekt läuft unter: https://${DOMAIN}"
  echo "🧭 Traefik Dashboard:  http://localhost:8090"
}
