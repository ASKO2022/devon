#!/usr/bin/env bash
# -------------------------------------------------------------------
# devon config – erzeugt/aktualisiert .devon/config.yaml, Services und .env
# -------------------------------------------------------------------

config() {
  # 🔧 Standardwerte (werden ggf. via CLI überschrieben)
  PROJECT_TYPE="django"
  PYTHON_VERSION="3.11"
  DB_TYPE="postgres"
  DB_IMAGE="postgres:15"
  DB_NAME="db"
  DB_USER="postgres"
  DB_PASSWORD="db"
  DB_PORT="5432"
  DOMAIN_BASE="devon.site"

  # CLI-Parameter auswerten (--type=django etc.)
  for arg in "$@"; do
    case $arg in
      --type=*) PROJECT_TYPE="${arg#*=}";;
      --python-version=*) PYTHON_VERSION="${arg#*=}";;
      --db-type=*) DB_TYPE="${arg#*=}";;
      --db-image=*) DB_IMAGE="${arg#*=}";;
      --db-name=*) DB_NAME="${arg#*=}";;
      --db-user=*) DB_USER="${arg#*=}";;
      --db-password=*) DB_PASSWORD="${arg#*=}";;
      --db-port=*) DB_PORT="${arg#*=}";;
      --domain-base=*) DOMAIN_BASE="${arg#*=}";;
    esac
  done

  echo "🔧 Erstelle .devon für Projekt: $PROJECT (type: $PROJECT_TYPE)"
  DOMAIN="${PROJECT}.${DOMAIN_BASE}"
  echo "🌐 Verwende Domain: https://$DOMAIN"
  mkdir -p "$MYDEV_DIR/services"

  CONFIG_TEMPLATE="$TEMPLATES/frameworks/$PROJECT_TYPE/config.yaml.tpl"
  if [ ! -f "$CONFIG_TEMPLATE" ]; then
    echo "❌ Kein Template für $PROJECT_TYPE unter $CONFIG_TEMPLATE"
    return 1
  fi
  echo "✅ Template gefunden: $CONFIG_TEMPLATE"

  # 🧩 config.yaml generieren
  sed \
    -e "s/{{PROJECT}}/$PROJECT/g" \
    -e "s/{{PROJECT_TYPE}}/$PROJECT_TYPE/g" \
    -e "s/{{PYTHON_VERSION}}/$PYTHON_VERSION/g" \
    -e "s/{{DB_TYPE}}/$DB_TYPE/g" \
    -e "s/{{DB_NAME}}/$DB_NAME/g" \
    -e "s/{{DB_USER}}/$DB_USER/g" \
    -e "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" \
    -e "s/{{DB_PORT}}/$DB_PORT/g" \
    "$CONFIG_TEMPLATE" > "$MYDEV_DIR/config.yaml"

  # Domain einfügen / überschreiben
  if command -v yq >/dev/null 2>&1; then
    yq -i ".domain = \"$DOMAIN\"" "$MYDEV_DIR/config.yaml"
  else
    grep -v '^domain:' "$MYDEV_DIR/config.yaml" > "$MYDEV_DIR/config.tmp"
    echo "domain: $DOMAIN" >> "$MYDEV_DIR/config.tmp"
    mv "$MYDEV_DIR/config.tmp" "$MYDEV_DIR/config.yaml"
  fi

  # YAML-Werte ins Environment laden
  load_cfg

  # Services aus Templates erzeugen
  for FILE in "$TEMPLATES/services/"*.yaml; do
    BASENAME=$(basename "$FILE")
    sed \
      -e "s/{{PROJECT}}/$PROJECT/g" \
      -e "s/{{PYTHON_VERSION}}/$PYTHON_VERSION/g" \
      -e "s/{{DB_TYPE}}/$DB_TYPE/g" \
      -e "s/{{DB_IMAGE}}/${DB_IMAGE:-postgres:15}/g" \
      -e "s/{{DB_NAME}}/$DB_NAME/g" \
      -e "s/{{DB_USER}}/$DB_USER/g" \
      -e "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" \
      -e "s/{{DB_PORT}}/$DB_PORT/g" \
      "$FILE" > "$MYDEV_DIR/services/$BASENAME"
  done

  # docker-compose.yaml generieren
  echo "🧩 Generiere docker-compose.yaml ..."
  {
    echo "services:"
    for FILE in "$MYDEV_DIR"/services/*.yaml; do
      echo ""
      sed 's/^/  /' "$FILE"
    done
    echo ""
    echo "volumes:"
    echo "  ${PROJECT}_dbdata:"
    echo ""
    echo "networks:"
    echo "  default:"
    echo "    name: devon"
    echo "    external: true"
  } > "$MYDEV_DIR/docker-compose.yaml"

  # .env generieren
  ENV_FILE="$MYDEV_DIR/.env"
  cat > "$ENV_FILE" <<EOF
PROJECT=$PROJECT
PYTHON_VERSION=$PYTHON_VERSION
DB_TYPE=$DB_TYPE
DB_IMAGE=${DB_IMAGE:-postgres:15}
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DOMAIN_BASE=$DOMAIN_BASE
DOMAIN=$DOMAIN
EOF

  # 🧩 Domain automatisch in /etc/hosts eintragen
  if [[ "$DOMAIN" =~ \.devon\.site$ ]]; then
    if ! grep -q "$DOMAIN" /etc/hosts; then
      echo "🧩 Füge Domain zu /etc/hosts hinzu: $DOMAIN"
      echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts >/dev/null
    else
      echo "✅ Domain bereits in /etc/hosts"
    fi
  else
    echo "ℹ️ DOMAIN_BASE ist '$DOMAIN_BASE' (kein /etc/hosts nötig)"
  fi

  echo ""
  echo "✅ .devon erfolgreich generiert!"
  echo "📁 Config: $MYDEV_DIR/config.yaml"
  echo "🔐 .env:   $ENV_FILE (nicht einchecken)"
}
