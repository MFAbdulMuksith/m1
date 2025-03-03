#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Define base directory for configurations and data
BASE_DIR="/opt/container"
PROMETHEUS_DIR="$BASE_DIR/prometheus"
ALERTMANAGER_DIR="$BASE_DIR/alertmanager"
GRAFANA_DIR="$BASE_DIR/grafana"
BLACKBOX_DIR="$BASE_DIR/blackbox"
LOKI_DIR="$BASE_DIR/loki"
PROMTAIL_DIR="$BASE_DIR/promtail"
TRAEFIK_DIR="$BASE_DIR/traefik"

# Create necessary directories
echo "Creating required directories..."
mkdir -p $PROMETHEUS_DIR $PROMETHEUS_DIR/data
mkdir -p $ALERTMANAGER_DIR
mkdir -p $GRAFANA_DIR $GRAFANA_DIR/data
mkdir -p $BLACKBOX_DIR
mkdir -p $LOKI_DIR
mkdir -p $PROMTAIL_DIR
mkdir -p $TRAEFIK_DIR

# Set proper permissions for base directory
chmod -R 755 $BASE_DIR

# Function to copy files if they do not exist and are non-empty
copy_if_not_exists() {
    local src=$1
    local dest=$2
    if [[ ! -f "$dest" ]]; then
        if [[ -s "$src" ]]; then  # Ensure source file exists and is non-empty
            echo "Copying $src to $dest"
            cp "$src" "$dest"
        else
            echo "Warning: Source file $src is missing or empty. Skipping."
        fi
    else
        echo "Skipping $dest (already exists)."
    fi
}

# Copy configuration files only if they don't already exist
echo "Copying configuration files (if not already present)..."
copy_if_not_exists ./prometheus/prometheus.yml $PROMETHEUS_DIR/prometheus.yml
copy_if_not_exists ./prometheus/alert.rules.yml $PROMETHEUS_DIR/alert.rules.yml
copy_if_not_exists ./alertmanager/alertmanager.yml $ALERTMANAGER_DIR/alertmanager.yml
copy_if_not_exists ./blackbox-exporter/config.yml $BLACKBOX_DIR/config.yml
copy_if_not_exists ./loki/loki-config.yaml $LOKI_DIR/loki-config.yaml
copy_if_not_exists ./promtail/promtail-config.yaml $PROMTAIL_DIR/promtail-config.yaml
copy_if_not_exists ./promtail/positions.yaml $PROMTAIL_DIR/positions.yaml

# Function to set permissions if the file exists
set_permissions() {
    local file=$1
    local owner=$2
    local mode=$3
    if [[ -f "$file" ]]; then
        echo "Setting permissions for $file"
        chown "$owner" "$file"
        chmod "$mode" "$file"
    fi
}

# Apply permissions to configuration files
set_permissions $PROMETHEUS_DIR/prometheus.yml root:root 644
set_permissions $PROMETHEUS_DIR/alert.rules.yml root:root 644
set_permissions $ALERTMANAGER_DIR/alertmanager.yml root:root 644
set_permissions $BLACKBOX_DIR/config.yml root:root 644
set_permissions $LOKI_DIR/loki-config.yaml root:root 644
set_permissions $PROMTAIL_DIR/promtail-config.yaml root:root 644
set_permissions $PROMTAIL_DIR/positions.yaml root:root 644

# Set ownership and permissions for data directories using dynamic UID/GID
echo "Setting data directory permissions..."
chown -R $(id -u nobody):$(id -g nobody) $PROMETHEUS_DIR/data
chmod -R 755 $PROMETHEUS_DIR/data

chown -R $(id -u grafana):$(id -g grafana) $GRAFANA_DIR/data
chmod -R 755 $GRAFANA_DIR/data

chown -R $(id -u promtail):$(id -g promtail) $PROMTAIL_DIR
chmod -R 755 $PROMTAIL_DIR

chown -R $(id -u loki):$(id -g loki) $LOKI_DIR
chmod -R 755 $LOKI_DIR

# Ensure Traefik acme.json file exists and has correct permissions
echo "Ensuring Traefik acme.json permissions..."
touch $TRAEFIK_DIR/acme.json
chmod 600 $TRAEFIK_DIR/acme.json

# Ensure Docker is installed
if ! command -v docker &>/dev/null; then
    echo "Error: Docker is not installed or not in PATH. Install it first."
    exit 1
fi

# Ensure Docker Compose is installed
if ! command -v docker-compose &>/dev/null && ! command -v docker compose &>/dev/null; then
    echo "Error: docker-compose is not installed. Install it first."
    exit 1
fi

# Ensure Docker network exists before running services
if ! docker network inspect monitor >/dev/null 2>&1; then
    echo "Creating 'monitor' Docker network..."
    docker network create monitor
fi

# Start the monitoring stack with correct docker-compose command
echo "Starting Docker services..."
if command -v docker-compose &>/dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

# Final status messages
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "✅ Monitoring environment setup completed!"
echo "🌍 Access your monitoring services at:"
echo "   📌 Prometheus: http://$IP_ADDRESS:9090"
echo "   📌 Grafana: http://$IP_ADDRESS:3000"
echo "   📌 Alertmanager: http://$IP_ADDRESS:9093"
echo "   📌 Traefik Dashboard: http://$IP_ADDRESS:8050"
echo "🚀 Happy monitoring!"
