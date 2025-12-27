# Quick Start Guide - Everything in Docker

This guide shows you how to run the entire ns-O-RAN-flexric system inside Docker containers.

## 🚀 Quick Start (One Command)

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/18-docker-complete-setup.sh
```

This will:
1. Build all Docker containers (30-60 minutes first time)
2. Start all services
3. Wait for services to be ready
4. Display access information

## 📋 Step-by-Step Guide

### Step 1: Build Containers

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/13-docker-build.sh
```

**Time**: 30-60 minutes (especially ns-3)

### Step 2: Start All Services

```bash
bash scripts/14-docker-start.sh
```

This starts:
- ✅ FlexRIC (nearRT-RIC) - Auto-starts
- ✅ e2sim (E2 Termination)
- ✅ ns-3 Simulator - With gui_trigger.py running
- ✅ GUI (RIC-TaaP Studio)
- ✅ InfluxDB
- ✅ Grafana

### Step 3: Access Services

- **RIC-TaaP Studio GUI**: http://localhost:8000
- **Grafana**: http://localhost:3000 (admin/admin)
- **InfluxDB**: http://localhost:8086

### Step 4: Run a Scenario

**Option A: From GUI**
1. Open http://localhost:8000
2. Click "Show form"
3. Select scenario
4. Click "Start"

**Option B: From Command Line**
```bash
bash scripts/16-docker-run-scenario.sh scenario-zero-with_parallel_loging.cc
```

### Step 5: Run an xApp

```bash
# Run KPM xApp
bash scripts/17-docker-run-xapp.sh kpm_rc

# Run Energy Saving xApp
bash scripts/17-docker-run-xapp.sh es_with_cell_util

# Run Handover xApp
bash scripts/17-docker-run-xapp.sh rc_handover_ctrl
```

## 🔧 Common Operations

### View Logs

```bash
cd docker

# All services
docker-compose logs -f

# Specific service
docker-compose logs -f flexric
docker-compose logs -f ns3-simulator
docker-compose logs -f gui
```

### Check Service Status

```bash
cd docker
docker-compose ps
```

### Stop All Services

```bash
bash scripts/15-docker-stop.sh
```

Or:
```bash
cd docker
docker-compose down
```

### Restart a Service

```bash
cd docker
docker-compose restart flexric
docker-compose restart ns3-simulator
```

### Execute Commands in Containers

```bash
cd docker

# Access ns-3 container
docker-compose exec ns3-simulator /bin/bash

# Access FlexRIC container
docker-compose exec flexric /bin/bash

# Access GUI container
docker-compose exec gui /bin/bash
```

## 📝 Running Scenarios Manually

### Inside ns-3 Container

```bash
cd docker
docker-compose exec ns3-simulator bash -c "cd /opt/ns3 && ./ns3 run 'scratch/scenario-zero-with_parallel_loging.cc --e2TermIp=e2sim --indicationPeriodicity=0.1 --simTime=1000'"
```

### Available Scenarios

- `scenario-zero-with_parallel_loging.cc`
- `scenario-three.cc`
- `Energy_Saving_with_load_balancing_scenario.cc`
- `orange-rf-channel-reconfiguration.cc`

## 📝 Running xApps Manually

### Inside FlexRIC Container

```bash
cd docker

# KPM xApp
docker-compose exec flexric bash -c "cd /opt/flexric/build/examples/xApp/c/kpm_rc && ./xapp_kpm_rc"

# Energy Saving xApp
docker-compose exec flexric bash -c "cd /opt/flexric/build/examples/xApp/c/orange && ./xapp_es_with_cell_util"

# Handover xApp
docker-compose exec flexric bash -c "cd /opt/flexric/build/examples/xApp/c/ctrl && ./xapp_rc_handover_ctrl"
```

## 🔍 Troubleshooting

### Services Not Starting

```bash
# Check logs
cd docker
docker-compose logs <service-name>

# Check status
docker-compose ps

# Restart
docker-compose restart <service-name>
```

### Port Conflicts

```bash
# Find process using port
sudo lsof -i :8000
sudo lsof -i :3000
sudo lsof -i :36421

# Kill process
sudo kill -9 <PID>
```

### Container Out of Memory

```bash
# Check memory usage
docker stats

# Increase Docker memory limit (Docker Desktop)
# Settings → Resources → Memory → Increase
```

### Rebuild After Changes

```bash
# Rebuild specific service
cd docker
docker-compose build --no-cache <service-name>
docker-compose up -d <service-name>

# Rebuild all
docker-compose build --no-cache
docker-compose up -d
```

## 📊 Monitoring

### View Resource Usage

```bash
docker stats
```

### View Container Logs

```bash
cd docker
docker-compose logs -f --tail=100
```

### Check Service Health

```bash
# Check if services are healthy
docker inspect ns-oran-flexric | grep -A 10 Health
docker inspect ns-oran-influxdb | grep -A 10 Health
```

## 🎯 Complete Workflow Example

```bash
# 1. Complete setup (first time only)
bash scripts/18-docker-complete-setup.sh

# 2. Wait for services (if not using script)
sleep 30

# 3. Open GUI
# Browser: http://localhost:8000

# 4. Run scenario
bash scripts/16-docker-run-scenario.sh scenario-zero-with_parallel_loging.cc

# 5. Run xApp (in separate terminal)
bash scripts/17-docker-run-xapp.sh kpm_rc

# 6. View results in GUI or Grafana
# GUI: http://localhost:8000
# Grafana: http://localhost:3000

# 7. Stop when done
bash scripts/15-docker-stop.sh
```

## 📚 Additional Resources

- **Complete Docker Guide**: [DOCKERIZATION_GUIDE.md](./DOCKERIZATION_GUIDE.md)
- **Main Documentation**: [../COMPLETE_DOCUMENTATION.md](../COMPLETE_DOCUMENTATION.md)

---

**Last Updated**: December 25, 2024

