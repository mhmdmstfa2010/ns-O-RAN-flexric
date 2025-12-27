# Comprehensive Documentation: ns-O-RAN-flexric Deployment Guide

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Prerequisites](#prerequisites)
4. [Installation Guide](#installation-guide)
5. [Modifications and Fixes](#modifications-and-fixes)
6. [Running the System](#running-the-system)
7. [Containerization](#containerization)
8. [Troubleshooting](#troubleshooting)
9. [Scripts Reference](#scripts-reference)

---

## Project Overview

**ns-O-RAN-flexric** is an open-source framework for comprehensive testing of xApps and rApps in 5G networks. It is part of the **RIC Testing as a Platform (RIC-TaaP)** project developed by Orange Innovation.

### Key Components

1. **FlexRIC**: RAN Intelligent Controller (nearRT-RIC)
2. **e2sim-kpmv3**: E2 Termination software for SCTP connection
3. **ns-3 Simulator**: Network simulator with mmWave and 5G-LENA support
4. **RIC-TaaP Studio**: Web-based GUI for monitoring and control
5. **Grafana**: Visualization platform for KPIs

### Supported Standards

- **E2AP v1.01**: E2 Application Protocol
- **KPM v3.00**: Key Performance Measurement
- **RC v1.03**: RAN Control

---

## System Architecture

```
┌─────────────────────────────────────────────────┐
│         RIC-TaaP Studio (Web GUI)              │
│         Port 8000                               │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         FlexRIC (nearRT-RIC)                    │
│         Port 36421                               │
│         - xApps (KPM, RC, ES, Handover)         │
└──────────────────┬──────────────────────────────┘
                   │ SCTP (E2AP Protocol)
┌──────────────────▼──────────────────────────────┐
│         e2sim-kpmv3                             │
│         E2 Termination                          │
│         - E2AP v1.01                            │
│         - KPM v3.00                              │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         ns-O-RAN Module                         │
│         (ns-3 Integration)                     │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         ns-3 Simulator                          │
│         (mmwave-LENA-oran)                      │
│         - 5G-LENA NR Module                     │
│         - Sionna Ray Tracing                    │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         InfluxDB                                │
│         Port 8086                               │
│         Time-series Database                    │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         Grafana                                 │
│         Port 3000                               │
│         Visualization Dashboard                 │
└─────────────────────────────────────────────────┘
```

---

## Prerequisites

### System Requirements

- **Operating System**: Ubuntu 20.04 LTS or later (tested on Ubuntu 24.04)
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: Minimum 20GB free space
- **CPU**: Multi-core processor recommended

### Required Software

1. **Build Tools**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y build-essential git cmake
   ```

2. **E2sim Dependencies**:
   ```bash
   sudo apt-get install -y \
     libsctp-dev \
     autoconf automake libtool \
     bison flex \
     libboost-all-dev \
     asn1c
   ```

3. **ns-3 Dependencies**:
   ```bash
   sudo apt-get install -y \
     g++ python3 python3-pip \
     libc6-dev \
     sqlite3 libsqlite3-dev \
     libeigen3-dev
   ```

4. **Python Dependencies**:
   ```bash
   sudo apt-get install -y python3-influxdb
   # OR if not available:
   pip3 install --break-system-packages influxdb
   ```

5. **Docker & Docker Compose** (for GUI):
   ```bash
   sudo apt-get install -y docker-compose
   ```

### Network Requirements

Ensure the following ports are available:
- **8000**: RIC-TaaP Studio GUI
- **3000**: Grafana
- **8086**: InfluxDB
- **36421**: FlexRIC (nearRT-RIC)

---

## Installation Guide

### Step 1: Clone the Project

```bash
cd /home/mhmd/Documents/o-ran
git clone --recurse-submodules https://github.com/Orange-OpenSource/ns-O-RAN-flexric
cd ns-O-RAN-flexric
```

**Important**: The `--recurse-submodules` flag is essential to download all required submodules.

### Step 2: Install Dependencies

Run the automated dependency installation script:

```bash
bash scripts/01-install-dependencies.sh
```

**What this script does**:
- Installs all build tools
- Installs E2sim requirements
- Installs ns-3 requirements
- Installs optional dependencies (SQLite, Eigen3)
- Installs Python dependencies (influxdb)

**Note for Ubuntu 24.04+**: The script handles the `externally-managed-environment` issue by using `python3-influxdb` from apt first, then falling back to pip with `--break-system-packages` if needed.

### Step 3: Install FlexRIC

FlexRIC must be installed separately as it's an external dependency.

```bash
bash scripts/02-install-flexric.sh
```

**What this script does**:
1. Clones FlexRIC from GitLab
2. Checks out the `oie-ric-taap-xapps` branch
3. Configures with E2AP v1.01 and KPM v3.00
4. Builds FlexRIC
5. Installs Service Models

**Important Configuration**:
- **E2AP Version**: v1.01 (not the default v2.03)
- **KPM Version**: v3.00 (not the default v2.03)
- **Branch**: `oie-ric-taap-xapps` (Orange's custom branch)

**Known Issue - RRC Messages**:
During build, RRC messages may fail with error:
```
-gen-UPER: Invalid argument
```
This is **optional** and does not affect system operation. The essential components (nearRT-RIC, xApps) will still be built successfully.

**Solution**: The build script continues even if RRC fails. You can use the system normally.

### Step 4: Build e2sim-kpmv3

```bash
bash scripts/03-build-e2sim.sh
```

**What this script does**:
1. Navigates to `e2sim-kpmv3/e2sim/`
2. Creates build directory
3. Runs `build_e2sim.sh` with LOG_LEVEL=2 (INFO)
4. Creates Debian package: `e2sim-dev_1.0.0_amd64.deb`

**Build Output**:
- Location: `e2sim-kpmv3/e2sim/build/e2sim-dev_1.0.0_amd64.deb`
- Size: ~3.4 MB

### Step 5: Build ns-3 Simulator

```bash
bash scripts/04-build-ns3.sh
```

**What this script does**:
1. Navigates to `mmwave-LENA-oran/`
2. Configures ns-3: `./ns3 configure`
3. Builds ns-3: `./ns3 build`

**Build Time**: 15-30 minutes depending on system performance

**What gets built**:
- ns-3 core simulator
- mmWave module
- 5G-LENA NR module
- O-RAN interface module
- Sionna Ray Tracing module
- All scenarios in `scratch/` directory

**Verification**:
After build, verify with:
```bash
cd mmwave-LENA-oran
./ns3 --version
./ns3 run --help
```

---

## Modifications and Fixes

### 1. Python Package Installation (Ubuntu 24.04)

**Problem**: Ubuntu 24.04 uses PEP 668, which prevents system-wide pip installations.

**Error**:
```
error: externally-managed-environment
```

**Solution**: Modified `scripts/01-install-dependencies.sh` to:
1. First try installing `python3-influxdb` from apt
2. If not available, use pip with `--break-system-packages` flag

**Code Change**:
```bash
# Use apt package for Ubuntu 24.04+ (externally-managed-environment)
sudo apt-get install -y python3-influxdb || {
    echo "python3-influxdb not found in apt, trying pip with --break-system-packages..."
    pip3 install --break-system-packages influxdb || echo "Warning: Could not install influxdb"
}
```

### 2. ASN1C Compiler Missing

**Problem**: FlexRIC build failed because ASN1C compiler was not found.

**Error**:
```
/bin/sh: 1: ASN1C_EXEC_PATH-NOTFOUND: not found
```

**Solution**: 
1. Added `asn1c` to dependency installation script
2. Added ASN1C path detection in FlexRIC build script

**Code Change**:
```bash
# In 01-install-dependencies.sh
sudo apt-get install -y \
  ... \
  asn1c

# In 02-install-flexric.sh
if ! command -v asn1c &> /dev/null; then
    echo "Error: asn1c not found. Please install it: sudo apt-get install asn1c"
    exit 1
fi
```

### 3. RRC Messages Build Failure

**Problem**: RRC messages build fails but is optional.

**Error**:
```
-gen-UPER: Invalid argument
make[2]: *** Error 64
```

**Solution**: Modified build script to continue even if RRC fails, as it's not essential for system operation.

**Code Change**:
```bash
# Build continues even if RRC fails
if make -j$(nproc) 2>&1 | tee build.log; then
    echo "Build completed successfully!"
else
    if [ -f "examples/ric/nearRT-RIC" ]; then
        echo "✓ Essential components built (RRC failed - optional)"
    fi
fi
```

### 4. Port Already in Use

**Problem**: FlexRIC fails to start because port 36421 is already in use.

**Error**:
```
errno = 98
Address already in use
```

**Solution**: Created script to detect and kill existing processes before starting.

**Code Change**:
```bash
# In 05-start-flexric.sh
PIDS=$(pgrep -f "nearRT-RIC" || true)
if [ -n "$PIDS" ]; then
    echo "Found existing nearRT-RIC process(es): $PIDS"
    read -p "Do you want to kill them and start new? (y/n) " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill -9 $PIDS 2>/dev/null || true
        sleep 2
    fi
fi
```

### 5. make install Fails Due to RRC

**Problem**: `sudo make install` tries to rebuild everything including RRC, which fails.

**Solution**: Use `make install -k` to continue despite errors, or use binaries directly from build directory.

**Alternative**: The system works without `make install`. Binaries can be used directly from:
- `/home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC`
- `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/*/xapp_*`

---

## Running the System

### Quick Start (All-in-One)

The easiest way to start everything:

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/12-start-all.sh
```

This script:
1. Checks all components
2. Kills existing processes
3. Starts FlexRIC
4. Starts GUI
5. Starts GUI Trigger
6. Displays access URLs

### Manual Start (Step-by-Step)

#### Terminal 1: Start FlexRIC

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/05-start-flexric.sh
```

**What to expect**:
- FlexRIC starts and listens on port 36421
- You'll see connection logs
- Keep this terminal open

**To stop**: Press `Ctrl+C` or run `bash scripts/11-kill-flexric.sh`

#### Terminal 2: Start GUI

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/06-start-gui.sh
```

**What this does**:
1. Detects your host IP address
2. Updates `docker-compose.yml` with the IP
3. Starts Docker containers:
   - GUI (RIC-TaaP Studio)
   - InfluxDB
   - Grafana

**What to expect**:
- Docker images will be built (first time only, takes 5-10 minutes)
- Containers start in background
- Access URLs displayed

**To stop**: 
```bash
cd mmwave-LENA-oran/GUI
docker-compose down
```

#### Terminal 3: Start GUI Trigger

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/mmwave-LENA-oran
python3 gui_trigger.py
```

**What this does**:
- Pushes ns-3 KPIs to InfluxDB
- Enables real-time data in GUI
- Keeps running in background

**To stop**: Press `Ctrl+C`

### Accessing the Dashboard

1. **Open your web browser**

2. **Access RIC-TaaP Studio**:
   ```
   http://YOUR_IP:8000
   ```
   Replace `YOUR_IP` with your machine's IP address (shown in terminal)

3. **Initial Setup in GUI**:
   - Click **"Connect to FlexRIC"** (if FlexRIC is running)
   - Click **"Show form"**
   - Select a scenario from the dropdown
   - Configure parameters (or use scenario defaults)
   - Click **"Start"**

4. **View Simulation**:
   - Cells and UEs appear on the grid
   - Click **"Source Data"** to see real-time KPIs
   - KPIs update every 1 second (or when xApp sends indications)

5. **Access Grafana** (optional):
   ```
   http://YOUR_IP:3000
   ```
   - Username: `admin`
   - Password: `admin`
   - Navigate to Dashboards → Manage
   - Select `per_Cell_stats` or `per_UE_stats`

### Running xApps

xApps are pre-built and located in:
```
/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/
```

**Available xApps**:
- `kpm_rc/xapp_kpm_rc` - KPM and RC monitoring
- `orange/xapp_es_with_cell_util` - Energy Saving with Cell Utilization
- `ctrl/xapp_rc_handover_ctrl` - Handover Control

**To run an xApp**:
```bash
cd /home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/kpm_rc
./xapp_kpm_rc
```

**Note**: xApp must be running when you want to see KPIs in GUI with FlexRIC connection enabled.

---

## Containerization

### Overview

All components can be containerized using Docker for easier deployment and isolation.

### Dockerfiles Created

1. **Dockerfile.flexric**: FlexRIC container
2. **Dockerfile.e2sim**: e2sim container
3. **Dockerfile.ns3**: ns-3 simulator container
4. **GUI Dockerfile**: Already exists in `mmwave-LENA-oran/GUI/`

### Docker Compose Setup

Location: `docker/docker-compose.yml`

**Services**:
- `flexric`: FlexRIC (nearRT-RIC)
- `e2sim`: E2 Termination
- `ns3-simulator`: ns-3 simulator
- `gui`: RIC-TaaP Studio
- `influxdb`: Time-series database
- `grafana`: Visualization

### Building Containers

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker
docker-compose build
```

**Build Time**: 30-60 minutes (especially ns-3)

### Running Containers

```bash
docker-compose up -d
```

### Accessing Services

- GUI: http://localhost:8000
- Grafana: http://localhost:3000
- InfluxDB: localhost:8086

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f flexric
docker-compose logs -f gui
```

### Stopping Containers

```bash
docker-compose down
```

### Important Notes for Containerization

1. **Volume Mounts**: Source code is mounted for development
2. **Network**: All services on `ns-oran-network` bridge
3. **Ports**: Mapped to host for external access
4. **Data Persistence**: Volumes for InfluxDB and Grafana data

---

## Troubleshooting

### Problem: FlexRIC Build Fails

**Symptoms**: Build stops with errors

**Solutions**:
1. **Check ASN1C**: `which asn1c` - should return path
2. **Check dependencies**: Run `scripts/01-install-dependencies.sh` again
3. **RRC Error**: Ignore if nearRT-RIC binary exists
4. **Clean build**: 
   ```bash
   cd /home/mhmd/Documents/o-ran/flexric/build
   rm -rf *
   cmake .. -DE2AP_VERSION=E2AP_V1 -DKPM_VERSION=KPM_V3_00
   make -j$(nproc)
   ```

### Problem: Port 36421 Already in Use

**Symptoms**: 
```
errno = 98
Address already in use
```

**Solutions**:
1. **Kill existing process**:
   ```bash
   bash scripts/11-kill-flexric.sh
   ```

2. **Find and kill manually**:
   ```bash
   pgrep -f "nearRT-RIC"
   kill -9 <PID>
   ```

3. **Use different port** (if supported):
   ```bash
   ./nearRT-RIC --port 36422
   ```

### Problem: GUI Doesn't Start

**Symptoms**: Docker containers fail to start

**Solutions**:
1. **Check Docker**:
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Check ports**:
   ```bash
   netstat -tuln | grep -E "8000|3000|8086"
   ```

3. **View logs**:
   ```bash
   cd mmwave-LENA-oran/GUI
   docker-compose logs
   ```

4. **Rebuild**:
   ```bash
   docker-compose down
   docker-compose up --build -d
   ```

### Problem: ns-3 Build Fails

**Symptoms**: Build stops or errors

**Solutions**:
1. **Check dependencies**:
   ```bash
   sudo apt-get install -y g++ python3 libc6-dev libeigen3-dev
   ```

2. **Clean and reconfigure**:
   ```bash
   cd mmwave-LENA-oran
   rm -rf build cmake-cache
   ./ns3 configure
   ./ns3 build
   ```

3. **Check Python version**: Should be 3.8+

### Problem: GUI Shows No Data

**Symptoms**: Dashboard empty, no KPIs

**Solutions**:
1. **Check FlexRIC connection**: Click "Connect to FlexRIC" in GUI
2. **Check xApp**: Ensure xApp is running
3. **Check GUI Trigger**: Ensure `gui_trigger.py` is running
4. **Check InfluxDB**:
   ```bash
   docker-compose -f mmwave-LENA-oran/GUI/docker-compose.yml exec influxdb influx -execute "SHOW DATABASES"
   ```

### Problem: e2sim Build Fails

**Symptoms**: build_e2sim.sh fails

**Solutions**:
1. **Check SCTP library**:
   ```bash
   sudo apt-get install -y libsctp-dev
   ```

2. **Check build script permissions**:
   ```bash
   chmod +x e2sim-kpmv3/e2sim/build_e2sim.sh
   ```

3. **Run manually**:
   ```bash
   cd e2sim-kpmv3/e2sim/build
   cmake .. -DDEV_PKG=1 -DLOG_LEVEL=2
   make package
   ```

### Problem: Python Dependencies Error (Ubuntu 24.04)

**Symptoms**: 
```
externally-managed-environment
```

**Solutions**:
1. **Use apt package**:
   ```bash
   sudo apt-get install -y python3-influxdb
   ```

2. **Use pip with flag**:
   ```bash
   pip3 install --break-system-packages influxdb
   ```

3. **Use virtual environment** (alternative):
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install influxdb
   ```

---

## Scripts Reference

### Installation Scripts

| Script | Purpose | Time |
|--------|---------|------|
| `00-setup-all.sh` | Complete automated setup | 30-60 min |
| `01-install-dependencies.sh` | Install all dependencies | 5-10 min |
| `02-install-flexric.sh` | Install and build FlexRIC | 10-20 min |
| `03-build-e2sim.sh` | Build e2sim-kpmv3 | 5-10 min |
| `04-build-ns3.sh` | Build ns-3 simulator | 15-30 min |

### Runtime Scripts

| Script | Purpose |
|--------|---------|
| `05-start-flexric.sh` | Start FlexRIC (nearRT-RIC) |
| `06-start-gui.sh` | Start RIC-TaaP Studio GUI |
| `07-start-gui-trigger.sh` | Start GUI trigger (KPI pusher) |
| `11-kill-flexric.sh` | Kill FlexRIC processes |
| `12-start-all.sh` | Start entire system |

### Utility Scripts

| Script | Purpose |
|--------|---------|
| `08-fix-flexric-build.sh` | Fix FlexRIC build issues |
| `09-install-flexric-manual.sh` | Manual FlexRIC installation |
| `10-skip-rrc-build.sh` | Disable RRC messages build |

### Script Details

#### 00-setup-all.sh
Master script that runs all installation steps in sequence.

**Usage**:
```bash
bash scripts/00-setup-all.sh
```

**What it does**:
1. Installs dependencies
2. Installs FlexRIC
3. Builds e2sim
4. Builds ns-3

#### 12-start-all.sh
Starts the entire system with one command.

**Usage**:
```bash
bash scripts/12-start-all.sh
```

**What it does**:
1. Verifies all components
2. Kills existing processes
3. Starts FlexRIC in background
4. Starts GUI
5. Starts GUI Trigger
6. Displays access information

---

## File Structure

```
ns-O-RAN-flexric/
├── scripts/                    # Automation scripts
│   ├── 00-setup-all.sh        # Complete setup
│   ├── 01-install-dependencies.sh
│   ├── 02-install-flexric.sh
│   ├── 03-build-e2sim.sh
│   ├── 04-build-ns3.sh
│   ├── 05-start-flexric.sh
│   ├── 06-start-gui.sh
│   ├── 07-start-gui-trigger.sh
│   ├── 08-fix-flexric-build.sh
│   ├── 09-install-flexric-manual.sh
│   ├── 10-skip-rrc-build.sh
│   ├── 11-kill-flexric.sh
│   └── 12-start-all.sh         # Start everything
│
├── docker/                     # Docker containerization
│   ├── Dockerfile.flexric
│   ├── Dockerfile.e2sim
│   ├── Dockerfile.ns3
│   ├── docker-compose.yml
│   └── README.md
│
├── e2sim-kpmv3/               # e2sim source (submodule)
│   └── e2sim/
│       └── build/
│           └── e2sim-dev_1.0.0_amd64.deb
│
├── mmwave-LENA-oran/          # ns-3 simulator (submodule)
│   ├── scratch/               # Scenarios
│   ├── GUI/                   # RIC-TaaP Studio
│   │   ├── docker-compose.yml
│   │   └── Dockerfile
│   └── gui_trigger.py         # KPI pusher
│
├── docs/                      # Documentation
├── fig/                       # Images and diagrams
│
├── README.md                  # Original README
├── DEPLOYMENT_GUIDE.md        # Deployment guide (Arabic)
├── QUICK_START.md             # Quick start guide
├── COMPREHENSIVE_DOCUMENTATION.md  # This file
└── FINAL_STATUS.md            # Final status summary
```

---

## Key Directories and Files

### FlexRIC
- **Binary**: `/home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC`
- **xApps**: `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/`
- **Config**: `/usr/local/etc/flexric/flexric.conf` (after install)

### e2sim
- **Package**: `e2sim-kpmv3/e2sim/build/e2sim-dev_1.0.0_amd64.deb`
- **Source**: `e2sim-kpmv3/e2sim/`

### ns-3
- **Executable**: `mmwave-LENA-oran/cmake-cache/ns3`
- **Scenarios**: `mmwave-LENA-oran/scratch/`
- **Build**: `mmwave-LENA-oran/cmake-cache/`

### GUI
- **Location**: `mmwave-LENA-oran/GUI/`
- **Docker Compose**: `mmwave-LENA-oran/GUI/docker-compose.yml`
- **Trigger Script**: `mmwave-LENA-oran/gui_trigger.py`

---

## Scenarios

### Available Scenarios

Located in `mmwave-LENA-oran/scratch/`:

1. **scenario-zero-with_parallel_loging.cc**
   - NSA 5G setup
   - 1 LTE eNB + 4 gNBs
   - Parallel logging enabled

2. **scenario-three.cc**
   - Basic 5G scenario
   - Handover testing

3. **Energy_Saving_with_load_balancing_scenario.cc**
   - Energy saving use case
   - Load balancing

4. **orange-rf-channel-reconfiguration.cc**
   - 5G-LENA scenario
   - RF channel reconfiguration

### Running a Scenario

**From GUI**:
1. Select scenario from dropdown
2. Click scenario flags to use defaults
3. Click "Start"

**From Command Line**:
```bash
cd mmwave-LENA-oran
./ns3 run "scratch/scenario-zero-with_parallel_loging.cc \
  --e2TermIp=127.0.0.1 \
  --indicationPeriodicity=0.1 \
  --simTime=1000 \
  --KPM_E2functionID=2 \
  --RC_E2functionID=3 \
  --N_MmWaveEnbNodes=4 \
  --N_Ues=3 \
  --CenterFrequency=3.5e9 \
  --Bandwidth=20e6"
```

---

## xApps Usage

### xapp_kpm_rc

**Purpose**: Monitor KPM and RC metrics

**Location**: `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/kpm_rc/`

**Usage**:
```bash
cd /home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/kpm_rc
./xapp_kpm_rc
```

**What it does**:
- Subscribes to KPM indications
- Logs KPIs to console
- Works with GUI for visualization

### xapp_es_with_cell_util

**Purpose**: Energy Saving based on cell utilization

**Location**: `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/orange/`

**Usage**:
```bash
cd /home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/orange
./xapp_es_with_cell_util
```

**What it does**:
- Monitors PRB usage per cell
- Switches cells on/off based on utilization
- Implements O-RAN Use Case 21

### xapp_rc_handover_ctrl

**Purpose**: Handover control

**Location**: `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/ctrl/`

**Usage**:
```bash
cd /home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/ctrl
./xapp_rc_handover_ctrl
```

**What it does**:
- Initiates handover requests
- Controls UE mobility
- Works with KPM xApp for cell selection

---

## Monitoring and KPIs

### Available KPIs

**Per UE KPIs** (26+ metrics):
- Position (x, y, cell)
- Throughput (PDCP, RLC)
- Latency (PDCP delay)
- SINR (serving, neighbor)
- Error rates
- Buffer sizes
- And more...

**Per Cell KPIs**:
- PRB usage
- Error rates
- Connected UEs
- And more...

### Viewing KPIs

**In RIC-TaaP Studio**:
1. Click "Source Data"
2. Real-time KPIs displayed
3. Updates every 1 second (or on indication)

**In Grafana**:
1. Access http://YOUR_IP:3000
2. Login: admin/admin
3. Dashboards → Manage
4. Select dashboard:
   - `per_Cell_stats`
   - `per_UE_stats`
5. Set time range
6. Enable auto-refresh

### KPI List

Full list available in: `docs/Grafana KPIs`

---

## Best Practices

### 1. Build Order

Always follow this order:
1. Dependencies
2. FlexRIC
3. e2sim
4. ns-3

### 2. Starting System

Recommended order:
1. FlexRIC first
2. GUI second
3. GUI Trigger third
4. xApp last (when needed)

### 3. Stopping System

1. Stop xApp (Ctrl+C)
2. Stop GUI Trigger (Ctrl+C)
3. Stop FlexRIC (Ctrl+C or kill script)
4. Stop GUI: `docker-compose down`

### 4. Development

- Keep source code mounted in Docker for live changes
- Use separate terminals for each component
- Check logs regularly
- Verify ports before starting

### 5. Troubleshooting

- Always check logs first
- Verify all components are built
- Check port availability
- Verify network connectivity
- Check Docker status (for GUI)

---

## Advanced Configuration

### FlexRIC Configuration

Edit: `/usr/local/etc/flexric/flexric.conf` (after install)

Or use command-line options:
```bash
./nearRT-RIC --help
```

### ns-3 Configuration

Edit: `mmwave-LENA-oran/.ns3rc` or use command-line:
```bash
./ns3 configure --help
```

### GUI Configuration

Edit: `mmwave-LENA-oran/GUI/docker-compose.yml`

Key settings:
- `NS3_HOST`: IP address of ns-3 host
- Port mappings
- Environment variables

### InfluxDB Configuration

Edit: `mmwave-LENA-oran/GUI/configuration.env`

Settings:
- Database name
- Username/password
- Retention policies

---

## Performance Considerations

### System Resources

**Minimum**:
- 8GB RAM
- 4 CPU cores
- 20GB disk

**Recommended**:
- 16GB RAM
- 8+ CPU cores
- 50GB+ disk
- SSD for faster builds

### Build Optimization

**Parallel Builds**:
- FlexRIC: `make -j$(nproc)`
- ns-3: Uses all cores by default

**Memory Issues**:
- Reduce parallelism: `make -j4`
- Close other applications
- Use swap if needed

### Runtime Performance

**GUI**:
- First load: 5-10 minutes (Docker build)
- Subsequent: Instant
- Memory: ~500MB per container

**ns-3**:
- Simulation speed depends on scenario
- Complex scenarios: slower
- Use shorter simTime for testing

---

## Security Considerations

### Network Security

- GUI and Grafana exposed on network
- Change default passwords
- Use firewall rules
- Consider VPN for remote access

### Docker Security

- Run containers as non-root when possible
- Use Docker secrets for passwords
- Keep images updated
- Scan for vulnerabilities

### System Security

- Keep system updated
- Use strong passwords
- Limit sudo access
- Monitor logs

---

## Maintenance

### Regular Tasks

1. **Update Dependencies**:
   ```bash
   sudo apt-get update && sudo apt-get upgrade
   ```

2. **Clean Build Artifacts**:
   ```bash
   # FlexRIC
   cd /home/mhmd/Documents/o-ran/flexric/build
   make clean
   
   # ns-3
   cd mmwave-LENA-oran
   ./ns3 clean
   ```

3. **Update Submodules**:
   ```bash
   git submodule update --remote --recursive
   ```

4. **Backup Data**:
   - InfluxDB volumes
   - Grafana dashboards
   - Configuration files

### Log Management

**FlexRIC Logs**:
- Check terminal output
- Configure logging level in build

**GUI Logs**:
```bash
cd mmwave-LENA-oran/GUI
docker-compose logs -f
```

**ns-3 Logs**:
- Check `ns3_run.log` in mmwave-LENA-oran/
- Terminal output

---

## Support and Resources

### Documentation

- **README.md**: Original project README
- **DEPLOYMENT_GUIDE.md**: Deployment guide (Arabic)
- **QUICK_START.md**: Quick start guide
- **This file**: Comprehensive documentation

### Scripts Help

Each script has comments explaining what it does. Read the script file for details.

### Troubleshooting

1. Check this documentation
2. Review script logs
3. Check component-specific logs
4. Verify prerequisites

### Community

- **GitHub**: https://github.com/Orange-OpenSource/ns-O-RAN-flexric
- **FlexRIC**: https://gitlab.eurecom.fr/mosaic5g/flexric
- **ns-O-RAN**: https://openrangym.com/ran-frameworks/ns-o-ran

---

## Conclusion

This documentation covers the complete setup, deployment, and operation of the ns-O-RAN-flexric system. All modifications, fixes, and workarounds have been documented to help users successfully deploy and operate the system.

**Key Takeaways**:
1. Follow installation order strictly
2. RRC build failures are normal and can be ignored
3. Use provided scripts for automation
4. Check logs when troubleshooting
5. System works without `make install` - binaries can be used directly

**Next Steps**:
1. Review this documentation
2. Follow installation steps
3. Start with `scripts/12-start-all.sh`
4. Explore the GUI and dashboards
5. Experiment with different scenarios

---

**Document Version**: 1.0  
**Last Updated**: December 25, 2024  
**Tested On**: Ubuntu 24.04 LTS

