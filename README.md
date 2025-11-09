# devon — lokale Dev-Tooling CLI

Kleine CLI, um in Sekunden lokale Projekte (z. B. Django) samt DB, Traefik-Routing und TLS-Zertifikat aufzusetzen.

> **Kurz:** `devon config --type=django && devon start` → läuft unter `https://<projekt>.devon.site`.

---

## Features

-   🧩 Projekt-Setup per Templates (`$DEVON_HOME/templates`)
-   🐍 Django + Postgres (weitere Frameworks/DBs erweiterbar)
-   🔒 Lokale TLS-Zertifikate via `mkcert` + Traefik
-   🧰 Helfer: `doctor`, `status`, `logs`, `db shell/export/import`
-   ⚙️ Konfiguration in `.devon/config.yaml` (bearbeitbar, maschinenlesbar via `yq`)

---

## Voraussetzungen

-   Docker & Docker Compose v2
-   `mkcert` (macOS: `brew install mkcert nss && mkcert -install`)
-   optional: `yq` (empfohlen, robustes YAML-Handling)

---

## Installation (lokal)

1. Script ausführbar machen:

```bash
chmod +x devon
```

2. Ins PATH legen (Beispiel macOS):

```bash
sudo install -m 0755 devon /usr/local/bin/devon
```

3. DEVON_HOME initialisieren (falls nicht vorhanden):

```bash
mkdir -p "$HOME/.devon"/{templates,traefik}
echo "0.0.1" > "$HOME/.devon/VERSION"
```

**Alternativ kannst du ein eigenes install.sh verwenden, das diese Schritte automatisiert.**

## Quickstart

```bash
# im Projektordner (z. B. ~/Projects/myapp)
devon config --type=django --python-version=3.12 --db-port=5433
devon start
devon open   # öffnet https://myapp.devon.site
```

Wichtigste Artefakte:

-   .devon/config.yaml – zentrale Konfiguration
-   .devon/docker-compose.yaml – generiert
-   .devon/.env – generiert (nicht committen)

## Nutzung

```bash
devon <command> [options]
```

Hauptbefehle:

-   config — generiert/aktualisiert .devon/
-   Flags:
    -   --type=<framework> (z. B. django)
    -   --python-version=<x.y> (z. B. 3.12)
    -   --db-type=<postgres|...>
    -   --db-image=<image:tag> (z. B. postgres:15)
    -   --db-name=<name> (default: db)
    -   --db-user=<user> (default: postgres)
    -   --db-password=<pw> (default: db)
    -   --db-port=<port> (default: 5432)
-   start / stop / restart
-   status — Containerstatus + URL
-   logs [django|db|traefik]
-   ssh — Shell im Django-Container
-   db shell|import <dump.sql>|export [out.sql]
-   outer start|stop|restart|logs — globaler Traefik
-   open — Browser öffnen
-   doctor — Diagnose inkl. TLS-Check
-   --version — Tool-Version anzeigen
-   help — Hilfe

## Verzeichnisstruktur (beispielhaft)

```bash
.
├─ devon                       # CLI
├─ templates/
│  ├─ frameworks/
│  │  └─ django/
│  │     ├─ config.yaml.tpl
│  │     └─ create.sh
│  └─ services/
│     └─ postgres.yaml
├─ traefik/
│  └─ global_certs/            # (im Repo ignoriert)
├─ VERSION                     # z. B. 0.0.1
└─ README.md
```

## Konfiguration

Alle relevanten Werte landen in .devon/config.yaml. Beispiele:

```bash
project_name: myapp
framework: django
domain: myapp.devon.site
python_version: 3.12
db:
  type: postgres
  name: db
  user: postgres
  password: db
  port: 5433
```

**Du kannst diese Datei manuell editieren; devon liest sie via yq (Fallback mit grep/awk).**

## Troubleshooting

-   devon doctor ausführen.
-   Prüfe, ob devon-traefik läuft (devon router start).
-   Stelle sicher, dass mkcert -install ausgeführt wurde (CA im System).
-   Prüfe /etc/hosts: 127.0.0.1 <projekt>.devon.site.
-   In Traefik-Logs schauen:

```bash
docker logs -f devon-traefik | grep -i "Configuration loaded"
```

## Sicherheitshinweis

Das Traefik-Dashboard ist lokal und ggf. mit --api.insecure=true aktiviert. Nur lokal verwenden. Nicht auf öffentlichen Hosts betreiben.

## Versionierung

-   Tool-Version kommt aus:
    1. DEVON_VERSION (ENV) oder
    2. $DEVON_HOME/VERSION oder
    3. Fallback 0.0.1

Taggen eines Releases:

```bash
echo "0.0.1" > "$HOME/.devon/VERSION"
git tag v0.0.1 && git push --tags
```

## Lizenz

**MIT — siehe LICENSE.**
