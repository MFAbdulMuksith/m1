#!/bin/bash

# Ensure script is run with sudo
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
mkdir -p $PROMETHEUS_DIR/data
mkdir -p $ALERTMANAGER_DIR
mkdir -p $GRAFANA_DIR/data
mkdir -p $BLACKBOX_DIR
mkdir -p $LOKI_DIR
mkdir -p $PROMTAIL_DIR
mkdir -p $TRAEFIK_DIR

# Set proper permissions
echo "Setting permissions..."
chmod -R 755 $BASE_DIR

# Copy configuration files
echo "Copying configuration files..."
sudo cp -R ./prometheus/prometheus.yml $PROMETHEUS_DIR/prometheus.yml
sudo cp -R ./prometheus/alert.rules.yml $PROMETHEUS_DIR/alert.rules.yml
sudo cp -R ./alertmanager/alertmanager.yml $ALERTMANAGER_DIR/alertmanager.yml
sudo cp -R ./blackbox-exporter/config.yml $BLACKBOX_DIR/config.yml
sudo cp -R ./loki/loki-config.yaml $LOKI_DIR/loki-config.yaml
sudo cp -R ./promtail/promtail-config.yaml $PROMTAIL_DIR/promtail-config.yaml
sudo cp -R ./promtail/positions.yaml $PROMTAIL_DIR/positions.yaml

# Set permissions for Prometheus
echo "Setting permissions for Prometheus..."
sudo chown root:root $PROMETHEUS_DIR/prometheus.yml
sudo chmod 644 $PROMETHEUS_DIR/prometheus.yml
sudo chown root:root $PROMETHEUS_DIR/alert.rules.yml
sudo chmod 644 $PROMETHEUS_DIR/alert.rules.yml
sudo chown -R 65534:65534 $PROMETHEUS_DIR/data
sudo chmod -R 755 $PROMETHEUS_DIR/data

# Set permissions for Grafana
echo "Setting permissions for Grafana..."
sudo chown -R 472:472 $GRAFANA_DIR/data
sudo chmod -R 755 $GRAFANA_DIR/data

# Set permissions for Promtail
echo "Setting permissions for Promtail..."
sudo chown -R promtail:promtail $PROMTAIL_DIR
sudo chmod -R 755 $PROMTAIL_DIR

# Set permissions for Loki
echo "Setting permissions for Loki..."
sudo chown -R 10001:10001 $LOKI_DIR
sudo chmod -R 755 $LOKI_DIR

# Set permissions for Traefik
echo "Setting permissions for Traefik..."
sudo touch $TRAEFIK_DIR/acme.json
sudo chmod 600 $TRAEFIK_DIR/acme.json

# Start the monitoring stack
echo "Starting Docker services..."
docker-compose up -d

echo "Monitoring Environment setup completed!"
echo "Test access to the services:"
echo "Prometheus: http://43.205.119.100:9090"
echo "Grafana: http://43.205.119.100:3000"
echo "Alertmanager: http://43.205.119.100:9093"
echo "Traefik Dashboard: http://43.205.119.100:8050"

