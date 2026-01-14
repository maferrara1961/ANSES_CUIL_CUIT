#!/bin/bash

# Enterprise Application Management Script
# Usage: ./manage.sh {start|stop|rebuild}

set -e

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
WEBAPPS_DIR="$BASE_DIR/webapps"
CONFIG_UI_DIR="$WEBAPPS_DIR/config-ui"
NETWORK_NAME="enterprise-net"

# Containers list for cleanup
CONTAINERS=("node-exporter" "cadvisor" "mssql" "prometheus" "grafana" "n8n" "tomcat" "nginx" "scraper")

function log() {
    echo -e "\033[0;34m[MANAGE]\033[0m $1"
}

function stop_all() {
    log "Stopping all services..."
    for container in "${CONTAINERS[@]}"; do
        if podman ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
            echo "Stopping and removing $container..."
            podman stop "$container" &>/dev/null || true
            podman rm "$container" &>/dev/null || true
        fi
    done
    log "All services stopped."
}

function build_frontend() {
    log "Building React Frontend (using containerized Node environment)..."
    
    if [ ! -d "$CONFIG_UI_DIR" ]; then
        echo "Error: Config UI directory not found at $CONFIG_UI_DIR"
        exit 1
    fi

    # Run build in a temporary node container to avoid host dependency issues
    # We mount the config-ui directory to /app
    podman run --rm \
        -v "$CONFIG_UI_DIR":/app \
        -w /app \
        node:18-alpine \
        /bin/sh -c "npm install && npm run build"
        
    log "Frontend build complete. Artifacts in $CONFIG_UI_DIR/dist"
}

function start() {
    log "Starting environment..."
    # We delegate to the existing setup-env.sh for the actual deployment logic
    "$SCRIPT_DIR/setup-env.sh"
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop_all
        ;;
    rebuild)
        stop_all
        build_frontend
        start
        ;;
    build-ui)
        build_frontend
        ;;
    *)
        echo "Usage: $0 {start|stop|rebuild|build-ui}"
        exit 1
        ;;
esac
