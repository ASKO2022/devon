---
# 🧩 DEVON – Lokale Entwicklungsumgebung

DEVON ist ein leichtes CLI-Tool,
mit dem du Webframeworks wie **Django, Flask, FastAPI** usw. in isolierten Containern starten kannst.
Es verwaltet Docker, Traefik und Projektkonfigurationen automatisch.
---

## 🚀 1. Voraussetzungen

Bevor du DEVON installierst, brauchst du:

| Tool                    | Zweck                        | Prüfung                  |
| ----------------------- | ---------------------------- | ------------------------ |
| **Docker**              | Container-Engine             | `docker version`         |
| **Docker Compose (v2)** | Multi-Service Orchestrierung | `docker compose version` |
| **yq**                  | YAML-Parser (CLI)            | `yq --version`           |
| **jq**                  | JSON Parser (optional)       | `jq --version`           |
| **bash**                | Shell (mind. v5)             | `bash --version`         |
| **mkcert** _(optional)_ | Lokale HTTPS-Zertifikate     | `mkcert -install`        |

---

## 📦 2. Installation (Entwicklermodus)

### Variante A — Direkt aus Repo (empfohlen)

Wenn du direkt im DEVON-Quellcode arbeitest:

```bash
# 1. Repository klonen (oder in deinen Pfad wechseln)
cd ~/Projects/devon

# 2. Symlink global setzen
sudo ln -sf ~/Projects/devon/devon /usr/local/bin/devon
```

➡️ Jetzt kannst du `devon` global aufrufen.
(Es erkennt automatisch, dass es im Entwicklungsmodus läuft.)

Prüfen:

```bash
devon help
```

Erwartet:

```
🧩 Entwicklungsmodus erkannt (/Users/alex/Projects/devon)
🌐 Verwende feste Domain-Basis: devon.site
devon – gib 'devon help' für alle Befehle ein.
```

---

### Variante B — Benutzerinstallation (optional)

Wenn du es für einen anderen Nutzer bereitstellen willst:

```bash
# 1. Nach ~/.devon kopieren
mkdir -p ~/.devon
cp -R ~/Projects/devon/* ~/.devon/

# 2. Symlink global setzen
sudo ln -sf ~/.devon/devon /usr/local/bin/devon
```

➡️ Beim Start erkennt Devon automatisch den **Installationsmodus**:

```
⚙️  Installationsmodus erkannt (/Users/alex/.devon)
```

---

## 🧱 3. Neues Projekt anlegen

```bash
mkdir ~/Projects/test-django
cd ~/Projects/test-django

# Erstelle DEVON-Setup
devon config --type=django
```

DEVON legt automatisch `.devon/config.yaml` und benötigte Service-Dateien an.

---

## 🐳 4. Projekt starten

```bash
devon start
```

DEVON:

-   startet Docker-Container (z. B. Django + DB)
-   richtet Traefik ein
-   zeigt die lokale Domain an

Beispielausgabe:

```
🧩 Entwicklungsmodus erkannt (/Users/alex/Projects/devon)
🌐 Verwende feste Domain-Basis: devon.site
🐍 Starte Django + Datenbank ...
🔗 URL: https://test-django.devon.site
```

---

## 🧰 5. Logs anzeigen

```bash
devon logs
```

oder

```bash
devon logs django
devon logs db
devon logs traefik
```

---

## 🧹 6. Projekt stoppen / löschen

```bash
devon stop        # stoppt Container
devon delete      # löscht Projekt (Container + Volumes)
```

---

## 🔍 7. Status & Diagnose

```bash
devon list        # zeigt alle Projekte
devon status      # Status eines Projekts
devon doctor      # prüft Docker, Traefik, Config
```

---

## ⚙️ 8. Router (Traefik) manuell steuern

```bash
devon router start
devon router stop
devon router logs
```

---

## 🧠 9. Entwicklungsmodus prüfen

```bash
devon version
```

oder direkt:

```bash
devon help
```

Wenn du das siehst:

```
🧩 Entwicklungsmodus erkannt (/Users/alex/Projects/devon)
```

→ alles läuft direkt aus deinem Code.
Wenn du siehst:

```
⚙️  Installationsmodus erkannt (/Users/alex/.devon)
```

→ du nutzt die installierte Benutzer-Version.

---

## 💡 Tipp: DEVON updaten (manuell)

Wenn du am Code was änderst, brauchst du nur:

```bash
sudo ln -sf ~/Projects/devon/devon /usr/local/bin/devon
hash -r
```

und die neueste Version ist sofort aktiv.

---

## 🧾 Zusammenfassung

| Aktion                   | Befehl                                                    |
| ------------------------ | --------------------------------------------------------- |
| Installation (Dev-Modus) | `sudo ln -sf ~/Projects/devon/devon /usr/local/bin/devon` |
| Neues Projekt            | `devon config --type=django`                              |
| Starten                  | `devon start`                                             |
| Logs ansehen             | `devon logs`                                              |
| Stoppen                  | `devon stop`                                              |
| Alle Projekte anzeigen   | `devon list`                                              |
| Router steuern           | `devon router start` / `devon router logs`                |

---
