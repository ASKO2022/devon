#!/usr/bin/env bash
# -------------------------------------------------------------------
# DEVON – Core-Library
# Basisfunktionen für alle Commands
# -------------------------------------------------------------------

MYDEV_DIR=".devon"

# --- Home vorbereiten und Assets ggf. kopieren ---
ensure_user_home() {
  local USER_HOME="$HOME/.devon"

  case "${DEVON_HOME:-}" in
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

  # Templates und Traefik übernehmen
  if [ ! -d "$DEVON_HOME/templates" ] || [ ! -d "$DEVON_HOME/traefik" ]; then
    mkdir -p "$DEVON_HOME"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$PKG_SHARE/templates" "$DEVON_HOME/" 2>/dev/null || true
      rsync -a "$PKG_SHARE/traefik" "$DEVON_HOME/" 2>/dev/null || true
    else
      cp -R "$PKG_SHARE/templates" "$DEVON_HOME/" 2>/dev/null || true
      cp -R "$PKG_SHARE/traefik" "$DEVON_HOME/" 2>/dev/null || true
    fi
    [ -f "$PKG_SHARE/VERSION" ] && cp "$PKG_SHARE/VERSION" "$DEVON_HOME/VERSION"
  fi

  mkdir -p "$DEVON_HOME/cache" "$DEVON_HOME/state" "$DEVON_HOME/traefik/global_certs"
  export DEVON_HOME
}

# --- ENV bevorzugen: .env > config.yaml ---
load_env_or_cfg() {
  if [ -f "$MYDEV_DIR/.env" ]; then
    set -a; . "$MYDEV_DIR/.env"; set +a
  else
    load_cfg
  fi
}

# --- YAML Loader mit Fallback ---
load_cfg() {
  local CFG="${MYDEV_DIR}/config.yaml"
  [ -f "$CFG" ] || { echo "❌ $CFG nicht gefunden"; return 1; }

  if command -v yq >/dev/null 2>&1; then
    PROJECT_TYPE="$(yq -r '.framework' "$CFG")"
    PYTHON_VERSION="$(yq -r '.python_version' "$CFG")"
    DOMAIN="$(yq -r '.domain' "$CFG")"
    DB_TYPE="$(yq -r '.db.type' "$CFG")"
    DB_NAME="$(yq -r '.db.name' "$CFG")"
    DB_USER="$(yq -r '.db.user' "$CFG")"
    DB_PASSWORD="$(yq -r '.db.password' "$CFG")"
    DB_HOST="$(yq -r '.db.host // "localhost"' "$CFG")"
    DB_PORT="$(yq -r '.db.port' "$CFG")"
  else
    val() { grep -E "^[[:space:]]*$1:" "$CFG" | head -n1 | awk -F': *' '{print $2}'; }
    PROJECT_TYPE="$(val framework)"
    PYTHON_VERSION="$(val python_version)"
    DOMAIN="$(val domain)"
    DB_TYPE="$(grep -A6 '^db:' "$CFG" | grep -E '^[[:space:]]*type:' | awk -F': *' '{print $2}')"
    DB_NAME="$(grep -A6 '^db:' "$CFG" | grep -E '^[[:space:]]*name:' | awk -F': *' '{print $2}')"
    DB_USER="$(grep -A6 '^db:' "$CFG" | grep -E '^[[:space:]]*user:' | awk -F': *' '{print $2}')"
    DB_PASSWORD="$(grep -A6 '^db:' "$CFG" | grep -E '^[[:space:]]*password:' | awk -F': *' '{print $2}')"
    DB_HOST="$(grep -A6 '^db:' "$CFG" | grep -E '^[[:space:]]*host:' | awk -F': *' '{print $2}')"
    DB_PORT="$(grep -A6 '^db:' "$CFG" | grep -E '^[[:space:]]*port:' | awk -F': *' '{print $2}')"
    [ -z "$DB_HOST" ] && DB_HOST="localhost"
  fi
}

# --- Version anzeigen ---
tool_version() {
  local v
  if [ -n "${DEVON_VERSION:-}" ]; then
    v="$DEVON_VERSION"
  elif [ -f "$DEVON_HOME/VERSION" ]; then
    v="$(tr -d ' \n\r' < "$DEVON_HOME/VERSION")"
  else
    v="0.0.1"
  fi
  echo "devon $v"
}

# --- YAML-Schlüssel setzen ---
cfg_set() {
  if ! command -v yq >/dev/null 2>&1; then
    echo "⚠️  yq nicht gefunden, cfg_set übersprungen."
    return 0
  fi
  local CFG="${MYDEV_DIR}/config.yaml"
  yq -i ".$1 = \"$2\"" "$CFG"
}
