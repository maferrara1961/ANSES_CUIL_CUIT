# AI Agent Context - ANSES_CUIL_CUIT Project

This document contains the complete context required for an AI agent to understand, modify, and maintain the `ANSES_CUIL_CUIT` project.

## 1. Project Overview
**Mission**: Automate tax and social security data retrieval (ANSES/AFIP) in Argentina, managing notifications via WhatsApp and Email, and visualizing data via dashboards.
**Target Environment**: macOS M1/M2 (ARM64) using **Podman** containers.

## 2. Technology Stack
- **Container Runtime**: Podman (OCI Standard).
- **Reverse Proxy**: Nginx (Alpine).
- **Frontend**: React (Vite) + Glassmorphism UI.
- **Backend (Scraper/API)**: Python Flask (Async Playwright support).
- **Backend (Legacy)**: Apache Tomcat 9 (Java WARs).
- **Database**: Azure SQL Edge (MSSQL compatible, ARM64 optimized).
- **Automation**: n8n (Workflow automation).
- **Observability**: Prometheus + Grafana.

## 3. Architecture & Networking
- **Network Name**: `enterprise-net`
- **Gateway**: Nginx acts as the single entry point on host port `80`.

| Service | Host Port | Internal Hostname | Description |
| :--- | :--- | :--- | :--- |
| **Nginx** | `80` | `nginx` | Reverse Proxy & Static File Server. |
| **Config UI** | `80/config/` | - | React App (served by Nginx). |
| **Scraper API** | `80/api/` | `scraper:5000` | Flask API for credentials & scraping. |
| **Tomcat** | `80/hello/` | `tomcat:8080` | Legacy Java Apps. |
| **Grafana** | `3000` | `grafana:3000` | Dashboards (User: `admin`/`admin`). |
| **n8n** | `5678` | `n8n:5678` | Workflow Editor. |
| **MSSQL** | `1433` | `mssql:1433` | Database (User: `sa`). |

## 4. Directory Structure
```text
/Users/mferrara/AG/podman/
├── scripts/
│   ├── manage.sh       # MAIN AUTOMATION SCRIPT (Start/Stop/Rebuild)
│   └── setup-env.sh    # Low-level deployment logic
├── webapps/
│   ├── config-ui/      # React Project Source
|   |   ├── src/        # React Components
|   |   └── dist/       # Built artifacts (mounted to Nginx)
│   └── anses/          # Legacy JSP apps
├── scraper/
│   ├── app/
│   │   ├── main.py     # Flask API Entrypoint
│   │   └── config.json # Credential Storage (JSON)
│   └── Dockerfile      # Python Image Definition
├── nginx/
│   └── nginx.conf      # Routing Configuration
└── ARCH_GUIDE.md       # Detailed Architecture Diagram
```

## 5. Automation Workflow (`scripts/manage.sh`)
**Always use this script** for lifecycle management to ensure consistency.

- **Start Environment**:
  ```bash
  ./scripts/manage.sh start
  ```
- **Stop Environment**:
  ```bash
  ./scripts/manage.sh stop
  ```
- **Rebuild & Deploy** (Crucial for React/Python changes):
  ```bash
  ./scripts/manage.sh rebuild
  ```
  *Note: `rebuild` uses a Dockerized Node environment to compile the React app, avoiding local Node version mismatches.*

## 6. Key Integration Points
### Configuration API
- **Endpoint**: `POST http://localhost/api/config`
- **Payload**: `{"whatsappToken": "...", "mailServer": "..."}`
- **Storage**: JSON file in `scraper/app/config.json`.

### Nginx Routing Rules
- `/config/` -> Serves `webapps/config-ui/dist` (React).
- `/api/` -> Proxies to `scraper:5000` (Flask).
- `/anses/` & `/hello/` -> Proxies to `tomcat:8080` (Java).

## 7. Versioning
- **Git Flow**: Main branch.
- **Releases**: Tagged versions (e.g., `v1.0.0`, `v1.1.0`).
- **Release Strategy**: Every significant change must include a new Git tag.
