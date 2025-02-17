#!/bin/bash

# Ensure script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo."
   exit 1
fi

# Define base directory
BASE_DIR="/opt/container"
PROMETHEUS_DIR="$BASE_DIR/prometheus"
ALERTMANAGER_DIR="$BASE_DIR/alertmanager"
GRAFANA_DIR="$BASE_DIR/grafana"
BLACKBOX_DIR="$BASE_DIR/blackbox"
LOKI_DIR="$BASE_DIR/loki"
PROMTAIL_DIR="$BASE_DIR/promtail"

# Create necessary directories
echo "Creating required directories..."
mkdir -p $PROMETHEUS_DIR/data
mkdir -p $ALERTMANAGER_DIR
mkdir -p $GRAFANA_DIR/data
mkdir -p $BLACKBOX_DIR
mkdir -p $LOKI_DIR/data
mkdir -p $PROMTAIL_DIR

# Ensure proper permissions
echo "Setting permissions..."
chmod -R 755 $BASE_DIR

# Copy configuration files
echo "Copying configuration files..."
cp ./prometheus/prometheus.yml $PROMETHEUS_DIR/prometheus.yml
cp ./prometheus/alert.rules.yml $PROMETHEUS_DIR/alert.rules.yml
cp ./alertmanager/alertmanager.yml $ALERTMANAGER_DIR/alertmanager.yml
cp ./blackbox-exporter/config.yml $BLACKBOX_DIR/config.yml
cp ./loki/loki-config.yaml $LOKI_DIR/loki-config.yaml
cp ./promtail/promtail-config.yaml $PROMTAIL_DIR/promtail-config.yaml
cp ./promtail/positions.yaml $PROMTAIL_DIR/positions.yaml

# Set permissions for Prometheus
chown -R 65534:65534 $PROMETHEUS_DIR/data
chmod -R 777 $PROMETHEUS_DIR/data

# Set permissions for Grafana
chown -R 472:472 $GRAFANA_DIR/data
chmod -R 775 $GRAFANA_DIR/data

# Set permissions for Loki
chown -R 10001:10001 $LOKI_DIR/data
chmod -R 775 $LOKI_DIR/data

# Set permissions for Promtail
chown -R root:root $PROMTAIL_DIR
chmod -R 644 $PROMTAIL_DIR/promtail-config.yaml
chmod -R 644 $PROMTAIL_DIR/positions.yaml

# Ensure Docker network exists
echo "Ensuring 'monitor' network exists..."
docker network inspect monitor >/dev/null 2>&1 || docker network create monitor

# Start services
echo "Starting Docker services..."
docker-compose up -d    # Start services in detached mode

# Service URLs
echo "Monitoring Environment setup completed!"
echo "Access services at:"
echo "Prometheus: http://localhost:9090"  # This is the correct port for Prometheus
echo "Grafana: http://localhost:3000"      # This is the correct port for Grafana
echo "Loki: http://localhost:3100"          # This is the correct port for Loki
echo "Alertmanager: http://localhost:9093"   # This is the correct port for Alertmanager
