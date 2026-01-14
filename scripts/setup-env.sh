#!/bin/bash

# Podman Enterprise Dev Environment Setup Script (Advanced Observability)
# Target: macOS M1 / ARM64
# Author: Antigravity Architect

set -e

# Configuration
NETWORK_NAME="enterprise-net"
MSSQL_IMAGE="mcr.microsoft.com/azure-sql-edge"
PROM_IMAGE="prom/prometheus:latest"
GRAFANA_IMAGE="grafana/grafana:latest"
N8N_IMAGE="n8nio/n8n:latest"
TOMCAT_IMAGE="tomcat:9-jre11-openjdk-slim"
NGINX_IMAGE="nginx:stable-alpine"
NODE_EXPORTER_IMAGE="prom/node-exporter:latest"
CADVISOR_IMAGE="gcr.io/cadvisor/cadvisor:latest"

# Directories
BASE_DIR="/Users/mferrara/AG/podman"
WEBAPPS_DIR="$BASE_DIR/webapps"
CONFIG_UI_DIR="$WEBAPPS_DIR/config-ui"
NGINX_DIR="$BASE_DIR/nginx"
PROM_CONFIG_DIR="$BASE_DIR/prometheus/config"
GRAFANA_PROV_DIR="$BASE_DIR/grafana/provisioning"

# Colors
SCRAPER_IMAGE="anses-scraper:latest"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}=== Initializing Podman Enterprise Environment ===${NC}"

# Function to manage container lifecycle
deploy_container() {
    local name=$1
    local cmd=$2

    if podman ps -a --format "{{.Names}}" | grep -q "^${name}$"; then
        echo -e "${YELLOW}Container '$name' exists. Recreating...${NC}"
        podman stop "$name" &>/dev/null || true
        podman rm "$name" &>/dev/null || true
    fi

    echo -e "${GREEN}Deploying $name...${NC}"
    eval "$cmd"
}

# Ensure directories exist
mkdir -p "$WEBAPPS_DIR" "$NGINX_DIR" "$PROM_CONFIG_DIR" "$GRAFANA_PROV_DIR/datasources" "$GRAFANA_PROV_DIR/dashboards"

# 1. Network Setup
if ! podman network exists $NETWORK_NAME; then
    podman network create $NETWORK_NAME
fi

# 2. Volume Setup
VOLUMES=("mssql_data" "prometheus_data" "n8n_data" "grafana_data")
for vol in "${VOLUMES[@]}"; do
    if ! podman volume exists $vol; then
        podman volume create $vol
    fi
done

# 2.5 Build Custom Images
echo -e "${BLUE}=== Building Custom Images ===${NC}"
podman build -t $SCRAPER_IMAGE -f "$BASE_DIR/scraper/Dockerfile" "$BASE_DIR/scraper"

# 3. Deploy Observability Agents (Exporters)
echo -e "${BLUE}=== Deploying Observability Agents ===${NC}"

# Node Exporter (System Metrics)
deploy_container "node-exporter" "podman run -d --name node-exporter \
  --network $NETWORK_NAME \
  $NODE_EXPORTER_IMAGE"

# cAdvisor (Container Metrics - Ajustado para Podman en macOS)
deploy_container "cadvisor" "podman run -d --name cadvisor \
  --network $NETWORK_NAME \
  --privileged \
  --pid=host \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/containers/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  $CADVISOR_IMAGE"

# 4. Deploy Core Services
echo -e "${BLUE}=== Deploying Core Services ===${NC}"

# SQL Server
deploy_container "mssql" "podman run -d --name mssql \
  --network $NETWORK_NAME \
  -v mssql_data:/var/opt/mssql \
  -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrongPassword123!' \
  $MSSQL_IMAGE"

# Prometheus
deploy_container "prometheus" "podman run -d --name prometheus \
  --network $NETWORK_NAME \
  -v prometheus_data:/prometheus \
  -v '$PROM_CONFIG_DIR/prometheus.yml':/etc/prometheus/prometheus.yml:ro \
  -v '$PROM_CONFIG_DIR/alert_rules.yml':/etc/prometheus/alert_rules.yml:ro \
  -p 9090:9090 \
  $PROM_IMAGE"

# Grafana
deploy_container "grafana" "podman run -d --name grafana \
  --network $NETWORK_NAME \
  -v grafana_data:/var/lib/grafana \
  -v '$GRAFANA_PROV_DIR':/etc/grafana/provisioning:ro \
  -p 3000:3000 \
  $GRAFANA_IMAGE"

# n8n
deploy_container "n8n" "podman run -d --name n8n \
  --network $NETWORK_NAME \
  -v n8n_data:/home/node/.n8n \
  -p 5678:5678 \
  $N8N_IMAGE"

# Tomcat
deploy_container "tomcat" "podman run -d --name tomcat \
  --network $NETWORK_NAME \
  -v '$WEBAPPS_DIR':/usr/local/tomcat/webapps \
  $TOMCAT_IMAGE"

# Scraper (Internal Service) - Start before Nginx for DNS resolution
deploy_container "scraper" "podman run -d --name scraper \
  --network $NETWORK_NAME \
  $SCRAPER_IMAGE"

# Nginx
deploy_container "nginx" "podman run -d --name nginx \
  --network $NETWORK_NAME \
  -v '$NGINX_DIR/nginx.conf':/etc/nginx/nginx.conf:ro \
  -v '$CONFIG_UI_DIR/dist':/usr/share/nginx/html/config-ui/dist:ro \
  -p 80:80 \
  $NGINX_IMAGE"


echo "App Demo: http://localhost/hello/"
echo "ANSES Flow Trigger: http://localhost/anses/"
echo "- Grafana: http://localhost:3000 (Check 'Enterprise Executive Observability' dashboard)"
