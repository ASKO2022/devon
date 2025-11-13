#!/usr/bin/env bash
# DEVON Installer
set -e
TARGET="$HOME/.devon"
mkdir -p "$TARGET"
cp -R lib commands templates traefik "$TARGET/"
cp devon "$TARGET/"
sudo ln -sf "$TARGET/devon" /usr/local/bin/devon
echo "✅ DEVON installiert unter $TARGET"
