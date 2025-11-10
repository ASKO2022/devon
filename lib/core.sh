#!/usr/bin/env bash
# =====================================================================
# core.sh – zentrale Funktionen für DEVON CLI
# =====================================================================

# sicheres Bash-Setup
set -euo pipefail

# Standard-Variablen
MYDEV_DIR=".devon"

# ---------------------------------------------------------------------
# 🔧 ensure_user_home – legt DEVON_HOME + Assets an
# ---------------------------------------------------------------------
ensure_user_home() {
  local USER_HOME="$HOME/.devon"

  case "$DEVON_HOME" in
    /usr/local/opt/*|/opt/homebrew/opt/*|*/Cellar/*|*/share/devon|*/opt/devon)
      DEVON_HOME="$USER_HOME"
      ;;
  esac
  [ -z "${DEVON_HOME:-}" ] && DEVON_HOME="$USER_HOME"

  local PKG_SHARE=""
  if command -v brew >/dev/null 2>&1; then
    local PFX; PFX="$(brew --prefix 2>/dev/null || true)"
    [ -d "$PFX/share/devon" ] && PKG_SHARE="$PFX/share/devon"
  fi
  [ -z "$PKG_SHARE" ] && PKG_SHARE="$(cd "$(dirname "$0")" && pwd)"

  # Templates / Traefik sicherstellen
  if [ ! -d "$DEVON_HOME/templates" ] || [ ! -d "$DEVON_HOME/traefik" ]; then
    mkdir -p "$DEVON_HOME"
    cp -R "$PKG_SHARE"/{templates,traefik} "$DEVON_HOME/" 2>/dev/null || true
  fi

  mkdir -p "$DEVON_HOME/cache" "$DEVON_HOME/state" "$DEVON_HOME/traefik/global_certs"
  export DEVON_HOME
}

# ---------------------------------------------------------------------
# 🧩 load_env_or_cfg – lädt Umgebungsvariablen
# ---------------------------------------------------------------------
load_env_or_cfg() {
  if [ -f "$MYDEV_DIR/.env" ]; then
    set -a; source "$MYDEV_DIR/.env"; set +a
  else
    load_cfg
  fi
}

# ---------------------------------------------------------------------
# ⚙️ load_cfg – YAML-Konfiguration laden
# ---------------------------------------------------------------------
load_cfg() {
  local CFG="${MYDEV_DIR}/config.yaml"
  [ -f "$CFG" ] || { echo "❌ Konfiguration fehlt ($CFG)"; exit 1; }

  if command -v yq >/dev/null 2>&1; then
    PROJECT_TYPE="$(yq -r '.framework' "$CFG")"
    PYTHON_VERSION="$(yq -r '.python_version' "$CFG")"
    DOMAIN="$(yq -r '.domain' "$CFG")"
    DB_NAME="$(yq -r '.db.name' "$CFG")"
    DB_USER="$(yq -r '.db.user' "$CFG")"
    DB_PASSWORD="$(yq -r '.db.password' "$CFG")"
  else
    PROJECT_TYPE=$(grep '^framework:' "$CFG" | awk '{print $2}')
    DOMAIN=$(grep '^domain:' "$CFG" | awk '{print $2}')
  fi
}

# ---------------------------------------------------------------------
# 📦 cfg_set – ändert Werte in YAML
# ---------------------------------------------------------------------
cfg_set() {
  local CFG="${MYDEV_DIR}/config.yaml"
  [ -f "$CFG" ] || return 1
  if command -v yq >/dev/null 2>&1; then
    yq -i ".$1 = \"$2\"" "$CFG"
  fi
}

# ---------------------------------------------------------------------
# 🧭 tool_version – zeigt DEVON Version
# ---------------------------------------------------------------------
tool_version() {
  local v="${DEVON_VERSION:-}"
  if [ -z "$v" ] && [ -f "$DEVON_HOME/VERSION" ]; then
    v="$(cat "$DEVON_HOME/VERSION" | tr -d '\n\r')"
  fi
  echo "${DEVON_NAME:-devon} ${v:-0.0.1}"
}
