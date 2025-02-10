#!/bin/bash

# chmod +x set.sh
# ./set.sh

# Define base directory for configurations and data
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
mkdir -p $LOKI_DIR
mkdir -p $PROMTAIL_DIR

# Create placeholder config files if they do not exist
echo "Ensuring configuration files exist..."

touch $PROMETHEUS_DIR/prometheus.yml
touch $PROMETHEUS_DIR/alert.rules.yml
touch $ALERTMANAGER_DIR/alertmanager.yml
touch $BLACKBOX_DIR/config.yml
touch $LOKI_DIR/loki-config.yaml
touch $PROMTAIL_DIR/promtail-config.yaml

# Set proper permissions
echo "Setting permissions..."
chmod -R 755 $BASE_DIR
chown -R $(whoami):$(whoami) $BASE_DIR

# Ensure Docker network exists
echo "Ensuring 'monitor' network exists..."
docker network inspect monitor >/dev/null 2>&1 || docker network create monitor

# Start the monitoring stack
echo "Starting Docker services..."
docker-compose up -d

echo "Environment setup complete!"

###################

# # Ensure the external network exists
# docker network create monitor

# # Ensure Prometheus data directory is writable
# sudo chown -R 65534:65534 /opt/container/prometheus/data
# sudo chmod -R 777 /opt/container/prometheus/data

# # Start the stack
# docker-compose up -d
