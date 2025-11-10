#!/usr/bin/env bash
# =====================================================================
# utils.sh – Hilfsfunktionen & Error Handling
# =====================================================================

# Fehlerbehandlung aktivieren
set -Euo pipefail
trap 'echo "❌ Fehler in Zeile $LINENO"; exit 1' ERR

# ---------------------------------------------------------------------
# 🎨 Farbige Ausgabe (optional)
# ---------------------------------------------------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# ---------------------------------------------------------------------
# 💬 Ausgabe-Helfer
# ---------------------------------------------------------------------
echo_ok()    { echo -e "${GREEN}✅ $*${RESET}"; }
echo_warn()  { echo -e "${YELLOW}⚠️  $*${RESET}"; }
echo_err()   { echo -e "${RED}❌ $*${RESET}" >&2; }
echo_info()  { echo "ℹ️  $*"; }

# ---------------------------------------------------------------------
# 🧠 check_dependency
# ---------------------------------------------------------------------
check_dependency() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo_err "$cmd ist nicht installiert."
    exit 1
  }
}
