# Loki Configuration Guide


## 📌 1. Overview

Loki is a log aggregation system designed for scalability and efficiency, inspired by Prometheus but optimized for logs.

---

## 📌 2. Configuration (`loki-config.yaml`)

### 🔹 **Key Sections**
- `server`: Defines HTTP and gRPC ports.
- `storage_config`: Specifies the storage backend (Filesystem in this case).
- `schema_config`: Defines how logs are stored.
- `query_range`: Optimizes log queries.
- `ruler`: Configures alerting using Alertmanager.
- `analytics`: Disables usage analytics.

---

## 📌 3. Installation Steps

### 🛠️ **Step 1: Install Loki**
```sh
wget https://github.com/grafana/loki/releases/latest/download/loki-linux-amd64 -O /usr/local/bin/loki
chmod +x /usr/local/bin/loki
```

### 🛠️ **Step 2: Create Required Directories**
```sh
mkdir -p /tmp/loki/chunks /tmp/loki/rules
chmod -R 777 /tmp/loki
```

### 🛠️ **Step 3: Run Loki**
```sh
loki --config.file=loki-config.yaml
```

To check if Loki is running:
```sh
curl -s http://localhost:3100/ready
```
Expected output: `"ready"`

---

---

## Configuration File: `loki-config.yaml`

Below is the provided `loki-config.yaml` file with explanations for each section:

```yaml
auth_enabled: false  # Disable authentication (not recommended for production)

server:
  http_listen_port: 3100  # HTTP port for Loki API
  grpc_listen_port: 9096  # gRPC port for internal communication

common:
  instance_addr: 127.0.0.1  # Address of the Loki instance
  path_prefix: /tmp/loki  # Base directory for Loki data (change for production)
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks  # Directory for storing log chunks
      rules_directory: /tmp/loki/rules  # Directory for storing alerting rules
  replication_factor: 1  # Number of replicas for data (1 for single-node setup)
  ring:
    kvstore:
      store: inmemory  # Use in-memory KV store (for single-node setup)

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true  # Enable in-memory query result caching
        max_size_mb: 100  # Maximum cache size in MB

schema_config:
  configs:
    - from: 2020-10-24  # Schema version start date
      store: tsdb  # Use TSDB for indexing
      object_store: filesystem  # Use filesystem for storage
      schema: v13  # Schema version
      index:
        prefix: index_  # Prefix for index files
        period: 24h  # Duration for each index period

ruler:
  alertmanager_url: http://43.205.119.100:9093  # URL for Alertmanager

# Disable anonymous usage reporting (optional)
analytics:
  reporting_enabled: false
```
