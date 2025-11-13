#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon open – öffnet das aktuelle Projekt im Browser
# -------------------------------------------------------------------

devon_open() {
  load_env_or_cfg
  local DOMAIN="${DOMAIN:-${PROJECT}.${DOMAIN_BASE}}"
  local URL="https://${DOMAIN}"

  echo "🌐 Öffne Projekt im Browser: $URL"

  if command -v open >/dev/null 2>&1; then
    /usr/bin/open "$URL"
    return
  fi


  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL"
    return
  fi

  if grep -qi microsoft /proc/version 2>/dev/null && command -v wslview >/dev/null 2>&1; then
    wslview "$URL"
    return
  fi

  echo "❌ Kein Browser-Öffner gefunden (open/xdg-open/wslview fehlen)."
  echo "🔗 Bitte manuell öffnen: $URL"
}
