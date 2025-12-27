# Docker Containerization Guide

## Overview

This directory contains Dockerfiles and docker-compose configuration to containerize the entire ns-O-RAN-flexric project.

**For complete documentation, see**: [DOCKERIZATION_GUIDE.md](./DOCKERIZATION_GUIDE.md)

## Architecture

```
┌─────────────────────────────────────────┐
│         GUI (Port 8000)                │
│         RIC-TaaP Studio                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         FlexRIC (Port 36421)            │
│         nearRT-RIC                      │
└──────────────┬──────────────────────────┘
               │ SCTP
┌──────────────▼──────────────────────────┐
│         e2sim                           │
│         E2 Termination                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         ns-3 Simulator                  │
│         mmwave-LENA-oran                 │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         InfluxDB (Port 8086)             │
│         Time-series DB                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Grafana (Port 3000)             │
│         Visualization                    │
└─────────────────────────────────────────┘
```

## Quick Start

### 1. Build all containers

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker
docker-compose build
```

### 2. Start all services

```bash
docker-compose up -d
```

### 3. Access services

- **RIC-TaaP Studio GUI**: http://localhost:8000
- **Grafana**: http://localhost:3000 (admin/admin)
- **InfluxDB**: localhost:8086

### 4. View logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f flexric
docker-compose logs -f gui
docker-compose logs -f ns3-simulator
```

### 5. Stop all services

```bash
docker-compose down
```

## Individual Services

### FlexRIC

```bash
# Build FlexRIC container
docker-compose build flexric

# Run FlexRIC
docker-compose up flexric

# Execute commands in container
docker-compose exec flexric /bin/bash
```

### e2sim

```bash
# Build e2sim container
docker-compose build e2sim

# Run e2sim
docker-compose up e2sim
```

### ns-3 Simulator

```bash
# Build ns-3 container
docker-compose build ns3-simulator

# Run ns-3 simulator
docker-compose up ns3-simulator

# Execute ns-3 commands
docker-compose exec ns3-simulator ./ns3 run "scratch/scenario-zero-with_parallel_loging.cc --e2TermIp=e2sim"
```

### GUI

```bash
# Build GUI container
docker-compose build gui

# Run GUI
docker-compose up gui
```

## Volumes

The following volumes are created to persist data:

- `influxdb_data`: InfluxDB database files
- `grafana_data`: Grafana dashboards and settings
- `flexric_data`: FlexRIC build artifacts
- `e2sim_data`: e2sim build artifacts
- `ns3_data`: ns-3 build artifacts

## Network

All services are connected via a bridge network `ns-oran-network` for inter-container communication.

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs [service-name]

# Check container status
docker-compose ps

# Restart service
docker-compose restart [service-name]
```

### Build fails

```bash
# Clean build
docker-compose build --no-cache [service-name]
```

### Port conflicts

Edit `docker-compose.yml` to change port mappings:

```yaml
ports:
  - "NEW_PORT:CONTAINER_PORT"
```

## Development

For development, you can mount source directories:

```yaml
volumes:
  - ../mmwave-LENA-oran:/opt/ns3
```

This allows live code changes without rebuilding containers.

## Production Considerations

1. **Security**: Change default passwords
2. **Resource Limits**: Add resource limits to services
3. **Health Checks**: Add health check configurations
4. **Backup**: Set up volume backups
5. **Monitoring**: Add monitoring and logging solutions

