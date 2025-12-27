# Complete Dockerization Guide for ns-O-RAN-flexric

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Detailed Setup](#detailed-setup)
6. [Container Details](#container-details)
7. [Usage Examples](#usage-examples)
8. [Development Workflow](#development-workflow)
9. [Troubleshooting](#troubleshooting)
10. [Production Deployment](#production-deployment)

---

## Overview

This guide provides complete instructions for containerizing and deploying the ns-O-RAN-flexric project using Docker and Docker Compose. All components (FlexRIC, e2sim, ns-3, GUI, InfluxDB, Grafana) are containerized for easy deployment and management.

### Benefits of Dockerization

- **Isolation**: Each component runs in its own isolated environment
- **Portability**: Run the same setup on any Docker-compatible system
- **Reproducibility**: Consistent environment across different machines
- **Easy Management**: Start/stop all services with single commands
- **Resource Control**: CPU and memory limits per service
- **Scalability**: Easy to scale individual services

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│         RIC-TaaP Studio (GUI)                  │
│         Container: ns-oran-gui                  │
│         Port: 8000                               │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         FlexRIC (nearRT-RIC)                    │
│         Container: ns-oran-flexric              │
│         Port: 36421                             │
└──────────────────┬──────────────────────────────┘
                   │ SCTP (E2AP Protocol)
┌──────────────────▼──────────────────────────────┐
│         e2sim (E2 Termination)                  │
│         Container: ns-oran-e2sim                │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         ns-3 Simulator                          │
│         Container: ns-oran-ns3                  │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         InfluxDB                                │
│         Container: ns-oran-influxdb             │
│         Port: 8086                               │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         Grafana                                 │
│         Container: ns-oran-grafana              │
│         Port: 3000                               │
└─────────────────────────────────────────────────┘
```

### Network Architecture

All containers are connected via a Docker bridge network (`ns-oran-network`) for inter-container communication. Services can communicate using container names as hostnames.

---

## Prerequisites

### System Requirements

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 1.29 or later (or Docker Compose V2)
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: Minimum 30GB free
- **CPU**: Multi-core processor (4+ cores recommended)

### Verify Installation

```bash
# Check Docker version
docker --version
# Should show: Docker version 20.10.x or later

# Check Docker Compose version
docker-compose --version
# Should show: docker-compose version 1.29.x or later

# Verify Docker is running
docker info
# Should show Docker system information
```

### Install Docker (if needed)

**Ubuntu/Debian**:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (to run without sudo)
sudo usermod -aG docker $USER
# Log out and log back in for changes to take effect

# Install Docker Compose
sudo apt-get update
sudo apt-get install -y docker-compose
```

---

## Quick Start

### Method 1: Using Scripts (Recommended)

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric

# Build all containers
bash scripts/13-docker-build.sh

# Start all services
bash scripts/14-docker-start.sh

# Stop all services
bash scripts/15-docker-stop.sh
```

### Method 2: Using Docker Compose Directly

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker

# Build all containers
docker-compose build

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Access Services

After starting, access:
- **RIC-TaaP Studio GUI**: http://localhost:8000
- **Grafana**: http://localhost:3000 (admin/admin)
- **InfluxDB**: http://localhost:8086

---

## Detailed Setup

### Step 1: Build Containers

**Build all containers**:
```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker
docker-compose build
```

**Build specific container**:
```bash
docker-compose build flexric
docker-compose build e2sim
docker-compose build ns3-simulator
docker-compose build gui
```

**Build without cache** (for clean build):
```bash
docker-compose build --no-cache
```

**Build time estimates**:
- FlexRIC: 10-20 minutes
- e2sim: 5-10 minutes
- ns-3: 30-60 minutes (longest)
- GUI: 2-5 minutes
- InfluxDB/Grafana: Instant (pre-built images)

### Step 2: Start Services

**Start all services**:
```bash
docker-compose up -d
```

**Start specific service**:
```bash
docker-compose up -d flexric
docker-compose up -d gui
```

**Start with logs visible**:
```bash
docker-compose up
# Press Ctrl+C to stop
```

### Step 3: Verify Services

**Check service status**:
```bash
docker-compose ps
```

**Check service logs**:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f flexric
docker-compose logs -f gui
docker-compose logs -f ns3-simulator
```

**Check service health**:
```bash
# Check if ports are listening
netstat -tuln | grep -E "8000|3000|8086|36421"

# Or use docker commands
docker ps
docker inspect ns-oran-flexric | grep -A 10 Health
```

---

## Container Details

### FlexRIC Container

**Image**: Built from `docker/Dockerfile.flexric`
**Container Name**: `ns-oran-flexric`
**Port**: 36421
**Volumes**: `flexric_data:/opt/flexric/build`

**Features**:
- Multi-stage build for smaller image size
- Non-root user for security
- Health checks enabled
- Resource limits configured

**Usage**:
```bash
# Execute commands in container
docker-compose exec flexric /bin/bash

# Run nearRT-RIC manually
docker-compose exec flexric ./nearRT-RIC

# View logs
docker-compose logs -f flexric
```

### e2sim Container

**Image**: Built from `docker/Dockerfile.e2sim`
**Container Name**: `ns-oran-e2sim`
**Volumes**: `e2sim_data:/opt/e2sim/build`

**Usage**:
```bash
# Execute commands in container
docker-compose exec e2sim /bin/bash

# Build e2sim (if needed)
docker-compose exec e2sim bash -c "cd /opt/e2sim && mkdir -p build && cd build && cmake .. -DDEV_PKG=1 -DLOG_LEVEL=2 && make package"
```

### ns-3 Simulator Container

**Image**: Built from `docker/Dockerfile.ns3`
**Container Name**: `ns-oran-ns3`
**Volumes**: 
- `../mmwave-LENA-oran:/opt/ns3` (source code)
- `ns3_data:/opt/ns3` (build artifacts)

**Usage**:
```bash
# Execute commands in container
docker-compose exec ns3-simulator /bin/bash

# Run scenario
docker-compose exec ns3-simulator ./ns3 run "scratch/scenario-zero-with_parallel_loging.cc --e2TermIp=e2sim --indicationPeriodicity=0.1 --simTime=1000"

# Build ns-3 (if needed)
docker-compose exec ns3-simulator ./ns3 configure
docker-compose exec ns3-simulator ./ns3 build
```

**Note**: For development, the source code is mounted as a volume, so changes are immediately available in the container.

### GUI Container

**Image**: Built from `mmwave-LENA-oran/GUI/Dockerfile`
**Container Name**: `ns-oran-gui`
**Port**: 8000

**Environment Variables**:
- `INFLUXDB_HOST=influxdb`
- `INFLUXDB_PORT=8086`
- `INFLUXDB_USER=admin`
- `INFLUXDB_PASSWORD=admin`
- `NS3_HOST=ns3-simulator`

**Usage**:
```bash
# View logs
docker-compose logs -f gui

# Restart GUI
docker-compose restart gui
```

### InfluxDB Container

**Image**: `influxdb:1.8-alpine`
**Container Name**: `ns-oran-influxdb`
**Port**: 8086

**Volumes**: `influxdb_data:/var/lib/influxdb`

**Usage**:
```bash
# Access InfluxDB CLI
docker-compose exec influxdb influx

# Execute query
docker-compose exec influxdb influx -execute "SHOW DATABASES"
```

### Grafana Container

**Image**: `grafana/grafana:8.0.2`
**Container Name**: `ns-oran-grafana`
**Port**: 3000

**Default Credentials**: admin/admin

**Volumes**: 
- `grafana_data:/var/lib/grafana`
- `./grafana/provisioning:/etc/grafana/provisioning`
- `./grafana/dashboards:/var/lib/grafana/dashboards`

---

## Usage Examples

### Example 1: Complete System Startup

```bash
# 1. Build all containers
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker
docker-compose build

# 2. Start all services
docker-compose up -d

# 3. Wait for services to be ready
sleep 30

# 4. Check status
docker-compose ps

# 5. View logs
docker-compose logs -f
```

### Example 2: Running a Scenario

```bash
# 1. Start all services
docker-compose up -d

# 2. Start FlexRIC (if not auto-started)
docker-compose exec flexric ./nearRT-RIC &

# 3. Run scenario in ns-3 container
docker-compose exec ns3-simulator ./ns3 run "scratch/scenario-zero-with_parallel_loging.cc \
  --e2TermIp=e2sim \
  --indicationPeriodicity=0.1 \
  --simTime=1000 \
  --KPM_E2functionID=2 \
  --RC_E2functionID=3 \
  --N_MmWaveEnbNodes=4 \
  --N_Ues=3"

# 4. Access GUI to view results
# Open: http://localhost:8000
```

### Example 3: Running xApp

```bash
# 1. Start FlexRIC
docker-compose exec flexric ./nearRT-RIC &

# 2. Run xApp in FlexRIC container
docker-compose exec flexric bash -c "cd /opt/flexric/build/examples/xApp/c/kpm_rc && ./xapp_kpm_rc"
```

### Example 4: Development Workflow

```bash
# 1. Start services
docker-compose up -d

# 2. Make changes to source code (mounted as volume)
# Edit files in: mmwave-LENA-oran/

# 3. Rebuild ns-3 (if needed)
docker-compose exec ns3-simulator ./ns3 build

# 4. Test changes
docker-compose exec ns3-simulator ./ns3 run "scratch/my_scenario.cc"
```

---

## Development Workflow

### Volume Mounts

Source code is mounted as volumes for live development:

```yaml
volumes:
  - ../mmwave-LENA-oran:/opt/ns3        # ns-3 source
  - ../e2sim-kpmv3:/opt/e2sim           # e2sim source
```

**Benefits**:
- Changes to source code are immediately available in containers
- No need to rebuild containers for code changes
- Easy debugging and testing

### Rebuilding After Code Changes

**For ns-3**:
```bash
docker-compose exec ns3-simulator ./ns3 build
```

**For e2sim**:
```bash
docker-compose exec e2sim bash -c "cd /opt/e2sim/build && make"
```

**For FlexRIC**:
```bash
# Rebuild container
docker-compose build flexric
docker-compose up -d flexric
```

### Debugging

**Access container shell**:
```bash
docker-compose exec <service-name> /bin/bash
```

**View real-time logs**:
```bash
docker-compose logs -f <service-name>
```

**Inspect container**:
```bash
docker inspect <container-name>
```

---

## Troubleshooting

### Problem: Container Won't Start

**Symptoms**: Container exits immediately or fails to start

**Solutions**:
```bash
# Check logs
docker-compose logs <service-name>

# Check container status
docker-compose ps

# Restart service
docker-compose restart <service-name>

# Rebuild container
docker-compose build --no-cache <service-name>
docker-compose up -d <service-name>
```

### Problem: Port Already in Use

**Symptoms**: Error: "port is already allocated"

**Solutions**:
```bash
# Find process using port
sudo lsof -i :8000
sudo lsof -i :3000
sudo lsof -i :8086
sudo lsof -i :36421

# Kill process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8001:8000"  # Change host port
```

### Problem: Build Fails

**Symptoms**: Docker build fails with errors

**Solutions**:
```bash
# Clean build (no cache)
docker-compose build --no-cache

# Check Docker resources
docker system df
docker system prune  # Clean unused resources

# Increase Docker memory (Docker Desktop)
# Settings → Resources → Memory → Increase to 8GB+
```

### Problem: Container Out of Memory

**Symptoms**: Container killed or OOM errors

**Solutions**:
```bash
# Check memory usage
docker stats

# Increase memory limits in docker-compose.yml
deploy:
  resources:
    limits:
      memory: 4G  # Increase limit
```

### Problem: Services Can't Communicate

**Symptoms**: Connection refused between containers

**Solutions**:
```bash
# Verify network
docker network ls
docker network inspect docker_ns-oran-network

# Check container IPs
docker-compose exec <service> hostname -i

# Test connectivity
docker-compose exec flexric ping e2sim
docker-compose exec ns3-simulator ping influxdb
```

### Problem: Data Not Persisting

**Symptoms**: Data lost after container restart

**Solutions**:
```bash
# Verify volumes
docker volume ls
docker volume inspect docker_influxdb_data

# Check volume mounts
docker-compose exec influxdb ls -la /var/lib/influxdb
```

---

## Production Deployment

### Security Considerations

1. **Change Default Passwords**:
   ```yaml
   environment:
     - INFLUXDB_PASSWORD=strong_password_here
     - GF_SECURITY_ADMIN_PASSWORD=strong_password_here
   ```

2. **Use Docker Secrets** (Docker Swarm):
   ```yaml
   secrets:
     - influxdb_password
     - grafana_password
   ```

3. **Non-Root Users**: All containers run as non-root users

4. **Network Isolation**: Use Docker networks to isolate services

5. **Resource Limits**: Configured in docker-compose.yml

### Resource Optimization

**CPU Limits**:
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
    reservations:
      cpus: '0.5'
```

**Memory Limits**:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 512M
```

### Monitoring

**Health Checks**: All services have health checks configured

**Logging**: Use Docker logging drivers:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Backup

**Backup Volumes**:
```bash
# Backup InfluxDB
docker run --rm -v docker_influxdb_data:/data -v $(pwd):/backup ubuntu tar czf /backup/influxdb-backup.tar.gz /data

# Backup Grafana
docker run --rm -v docker_grafana_data:/data -v $(pwd):/backup ubuntu tar czf /backup/grafana-backup.tar.gz /data
```

**Restore Volumes**:
```bash
# Restore InfluxDB
docker run --rm -v docker_influxdb_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/influxdb-backup.tar.gz -C /
```

### Scaling

**Scale Services** (Docker Swarm):
```bash
docker service scale ns-oran-gui=3
```

**Load Balancing**: Use reverse proxy (nginx/traefik) for GUI

---

## Best Practices

1. **Use Scripts**: Use provided scripts for common operations
2. **Monitor Resources**: Regularly check `docker stats`
3. **Clean Up**: Periodically run `docker system prune`
4. **Backup Data**: Regular backups of volumes
5. **Update Images**: Keep base images updated
6. **Log Management**: Configure log rotation
7. **Health Checks**: Monitor service health
8. **Resource Limits**: Set appropriate limits

---

## Additional Resources

- **Docker Documentation**: https://docs.docker.com/
- **Docker Compose Documentation**: https://docs.docker.com/compose/
- **Project Documentation**: See `COMPLETE_DOCUMENTATION.md`

---

**Last Updated**: December 25, 2024  
**Version**: 1.0

