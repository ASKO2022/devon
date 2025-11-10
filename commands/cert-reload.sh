#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon cert-reload – Hinweis zur Traefik-Konfig-Neuladung
# -------------------------------------------------------------------

cert_reload() {
  echo "🔁 Traefik lädt den file-provider automatisch bei Dateiänderungen."
  echo "ℹ️  Logs ansehen mit:"
  echo "   docker logs -f devon-traefik | grep -i 'Configuration loaded'"
}
