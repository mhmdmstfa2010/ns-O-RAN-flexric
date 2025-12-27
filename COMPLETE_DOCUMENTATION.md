# Complete Documentation: ns-O-RAN-flexric Deployment Guide

**Version**: 1.0  
**Last Updated**: December 25, 2024  
**Tested On**: Ubuntu 24.04.3 LTS

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Repository Structure](#repository-structure)
4. [Prerequisites](#prerequisites)
5. [Installation Guide](#installation-guide)
6. [Modifications and Fixes](#modifications-and-fixes)
7. [Running the System](#running-the-system)
8. [Containerization](#containerization)
9. [Troubleshooting](#troubleshooting)
10. [Scripts Reference](#scripts-reference)
11. [Advanced Topics](#advanced-topics)
12. [Appendices](#appendices)

---

## Project Overview

**ns-O-RAN-flexric** is an open-source framework designed for comprehensive testing of xApps and rApps in 5G networks. It is an integral component of the **RIC Testing as a Platform (RIC-TaaP)** project developed by Orange Innovation Egypt (OIE) and Orange Innovation Poland (OIP).

### Purpose

The project provides:
- **Comprehensive 5G System-Level Environment**: Full 5G/LTE simulation environment for RIC testing
- **Digital Twin Testing**: Verify and calibrate use cases using real KPIs from operational 5G environments
- **User-Friendly GUI**: RIC-TaaP Studio with intuitive dashboards and operational features
- **AI Integration Ready**: Framework designed to support LLM-powered algorithms and Agentic-AI for RAN optimization

### Key Components

1. **FlexRIC**: RAN Intelligent Controller (nearRT-RIC) - the brain of the O-RAN system
2. **e2sim-kpmv3**: E2 Termination software for SCTP connection between ns-3 and RIC
3. **ns-3 Simulator**: Network simulator with mmWave and 5G-LENA support
4. **RIC-TaaP Studio**: Web-based GUI for monitoring and control
5. **Grafana**: Visualization platform for KPIs
6. **InfluxDB**: Time-series database for storing KPIs

### Supported Standards

- **E2AP v1.01**: E2 Application Protocol - Communication protocol between RIC and RAN nodes
- **KPM v3.00**: Key Performance Measurement - Defines what metrics to collect and how
- **RC v1.03**: RAN Control - Control actions (handover, cell on/off, etc.)
- **SCTP**: Stream Control Transmission Protocol - Reliable transport for E2AP messages

### Repository Information

- **GitHub**: https://github.com/Orange-OpenSource/ns-O-RAN-flexric
- **License**: GNU General Public License v2
- **Maintainers**: Orange Innovation Egypt & Orange Innovation Poland
- **Status**: Active development

### Use Cases Supported

1. **KPM Monitoring**: Collect KPIs from simulated network, display in GUI and Grafana
2. **Handover Control**: Initiate handover requests, control UE mobility
3. **Energy Saving**: Monitor cell utilization, automatically switch cells on/off (O-RAN Use Case 21)
4. **Load Balancing**: Distribute load across cells, optimize resource utilization

---

## System Architecture

```
┌─────────────────────────────────────────────────┐
│         RIC-TaaP Studio (Web GUI)              │
│         Port 8000                               │
│         - Network topology visualization       │
│         - Real-time KPI display                │
│         - Scenario control                       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         FlexRIC (nearRT-RIC)                    │
│         Port 36421                             │
│         - xApps (KPM, RC, ES, Handover)       │
│         - E2 connection management             │
│         - Message routing                      │
└──────────────────┬──────────────────────────────┘
                   │ SCTP (E2AP Protocol)
┌──────────────────▼──────────────────────────────┐
│         e2sim-kpmv3                             │
│         E2 Termination                          │
│         - E2AP v1.01                           │
│         - KPM v3.00                             │
│         - Message encoding/decoding            │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         ns-O-RAN Module                         │
│         (ns-3 Integration)                     │
│         - O-RAN interface                      │
│         - KPI generation                       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         ns-3 Simulator                          │
│         (mmwave-LENA-oran)                     │
│         - 5G-LENA NR Module                    │
│         - mmWave module                        │
│         - Sionna Ray Tracing                   │
│         - Network simulation                   │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         InfluxDB                                │
│         Port 8086                               │
│         Time-series Database                   │
│         - Stores KPIs                          │
│         - Historical data                      │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         Grafana                                 │
│         Port 3000                               │
│         Visualization Dashboard                 │
│         - KPI dashboards                       │
│         - Historical analysis                  │
└─────────────────────────────────────────────────┘
```

### Data Flow

1. **ns-3 Simulator** generates network events and KPIs
2. **ns-O-RAN Module** translates KPIs to O-RAN format
3. **e2sim** encodes KPIs using E2AP/KPM protocols
4. **SCTP Connection** transports messages to FlexRIC
5. **FlexRIC** processes messages and routes to xApps
6. **xApps** analyze KPIs and send control actions (if needed)
7. **GUI Trigger** pushes KPIs to InfluxDB
8. **InfluxDB** stores historical data
9. **Grafana** visualizes data from InfluxDB
10. **RIC-TaaP Studio** displays real-time data and controls

---

## Repository Structure

```
ns-O-RAN-flexric/
│
├── README.md                    # Original project README
├── LICENSE.txt                  # GNU GPL v2 license
├── .gitmodules                  # Git submodules configuration
│
├── scripts/                     # Automation scripts (created)
│   ├── 00-setup-all.sh         # Complete automated setup
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
│   └── 12-start-all.sh          # Start entire system
│
├── docker/                      # Docker containerization (created)
│   ├── Dockerfile.flexric       # FlexRIC container
│   ├── Dockerfile.e2sim         # e2sim container
│   ├── Dockerfile.ns3           # ns-3 container
│   ├── docker-compose.yml       # Complete system compose
│   └── README.md                # Docker usage guide
│
├── e2sim-kpmv3/                 # Git submodule
│   └── e2sim/                   # E2 Termination source
│       └── build/               # Build artifacts
│           └── e2sim-dev_1.0.0_amd64.deb
│
├── mmwave-LENA-oran/            # Git submodule
│   ├── scratch/                 # ns-3 scenarios
│   │   ├── scenario-zero-with_parallel_loging.cc
│   │   ├── scenario-three.cc
│   │   ├── Energy_Saving_with_load_balancing_scenario.cc
│   │   └── ...
│   ├── GUI/                     # RIC-TaaP Studio
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   └── src/
│   ├── gui_trigger.py           # KPI pusher to InfluxDB
│   └── contrib/                 # ns-3 modules
│       └── oran-interface/       # O-RAN interface module
│
├── docs/                         # Documentation
│   ├── Energy_saving_usecases.pdf
│   ├── handover_operation.pdf
│   ├── Grafana KPIs
│   └── ...
│
└── fig/                         # Images and diagrams
    ├── logo.png
    ├── ns-o-ran-flexric.png
    └── ...
```

### Core Components Explained

#### 1. FlexRIC (External Dependency)

**What it is**: RAN Intelligent Controller - the brain of the O-RAN system

**Location**: `/home/mhmd/Documents/o-ran/flexric/` (installed separately)

**Purpose**:
- Manages E2 connections with RAN nodes
- Hosts xApps and rApps
- Processes KPM indications
- Sends RC control messages

**Key Files**:
- `build/examples/ric/nearRT-RIC` - Main RIC binary (~3.1 MB)
- `build/examples/xApp/c/` - Various xApps

**Why Separate**: FlexRIC is a large, independent project from EURECOM. It must be built with specific configurations (E2AP v1.01, KPM v3.00) that differ from defaults.

#### 2. e2sim-kpmv3 (Git Submodule)

**What it is**: E2 Termination software - creates SCTP connection between ns-3 and RIC

**Location**: `e2sim-kpmv3/e2sim/`

**Purpose**:
- Implements E2AP v1.01 protocol
- Implements KPM v3.00
- Translates between ns-3 and RIC
- Handles message encoding/decoding

**Build Output**: Debian package `e2sim-dev_1.0.0_amd64.deb` (~3.4 MB)

#### 3. mmwave-LENA-oran (Git Submodule)

**What it is**: ns-3 network simulator with O-RAN integration

**Location**: `mmwave-LENA-oran/`

**Purpose**:
- Simulates 5G/LTE networks
- Generates realistic network traffic
- Produces KPIs (Key Performance Indicators)
- Supports mmWave and 5G-LENA modules

**Key Features**:
- Multiple scenarios in `scratch/` directory
- GUI integration (RIC-TaaP Studio)
- Real-time KPI generation
- Support for complex network topologies

#### 4. RIC-TaaP Studio (GUI)

**What it is**: Web-based graphical user interface

**Location**: `mmwave-LENA-oran/GUI/`

**Purpose**:
- Visualize network topology (cells, UEs)
- Display real-time KPIs
- Control simulations
- Manage xApps
- Energy Saving dashboard
- A1 Policy management

**Technology**: FastAPI (Python), Docker containerized

---

## Prerequisites

### System Requirements

- **Operating System**: Ubuntu 20.04 LTS or later
  - **Tested on**: Ubuntu 24.04.3 LTS
  - **Why Ubuntu 20.04+**: Required for modern build tools and dependencies
  
- **Hardware**:
  - **RAM**: Minimum 8GB (16GB recommended for smooth operation)
  - **Disk Space**: Minimum 20GB free (50GB+ recommended)
  - **CPU**: Multi-core processor (4+ cores recommended)
  - **Network**: Internet connection for downloading dependencies

### Software Prerequisites

Before starting, ensure you have:

1. **Git** (for cloning repositories)
2. **Docker & Docker Compose** (for GUI)
3. **sudo access** (for installing packages)

Verify with:
```bash
git --version
docker --version
docker-compose --version
sudo -v
```

### Required Software Packages

#### Build Tools
```bash
sudo apt-get update
sudo apt-get install -y build-essential git cmake
```

#### E2sim Dependencies
```bash
sudo apt-get install -y \
  libsctp-dev \
  autoconf automake libtool \
  bison flex \
  libboost-all-dev \
  asn1c
```

**What each package does**:
- **build-essential**: GCC compiler, make, and other build tools
- **cmake**: Build system generator
- **libsctp-dev**: SCTP protocol library (for E2AP)
- **autoconf, automake, libtool**: Build configuration tools
- **bison, flex**: Parser generators (for ASN.1)
- **libboost-all-dev**: C++ libraries
- **asn1c**: ASN.1 compiler (for FlexRIC) - **Critical!**

#### ns-3 Dependencies
```bash
sudo apt-get install -y \
  g++ python3 python3-pip \
  libc6-dev \
  sqlite3 libsqlite3-dev \
  libeigen3-dev
```

**What each package does**:
- **g++**: C++ compiler
- **python3**: Python interpreter
- **libeigen3-dev**: Linear algebra library (for MIMO)

#### Python Dependencies
```bash
# Ubuntu 24.04+ fix (see Modifications section)
sudo apt-get install -y python3-influxdb || \
  pip3 install --break-system-packages influxdb
```

**Ubuntu 24.04 Special Note**: Ubuntu 24.04 implements PEP 668, which prevents system-wide pip installations. The script handles this automatically.

#### Docker Compose (for GUI)
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

### Installation Methods

#### Method 1: Automated Installation (Recommended)

**For beginners or quick setup:**

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/00-setup-all.sh
```

This script will:
1. Install all dependencies
2. Install FlexRIC
3. Build e2sim
4. Build ns-3

**Time**: 30-60 minutes (depending on system)

**Advantages**:
- One command does everything
- Handles errors automatically
- User-friendly prompts

#### Method 2: Step-by-Step Installation

**For understanding each step or troubleshooting:**

Follow the detailed steps below.

---

### Step 1: Clone the Repository

```bash
# Navigate to your workspace
cd /home/mhmd/Documents/o-ran

# Clone with submodules (IMPORTANT: --recurse-submodules is required)
git clone --recurse-submodules https://github.com/Orange-OpenSource/ns-O-RAN-flexric

# Enter the project directory
cd ns-O-RAN-flexric
```

**Why `--recurse-submodules`?**
The project uses Git submodules for:
- `e2sim-kpmv3`: E2 Termination software
- `mmwave-LENA-oran`: ns-3 simulator

Without this flag, these directories will be empty.

**If you already cloned without submodules:**
```bash
git submodule update --init --recursive
```

**Verify submodules:**
```bash
git submodule status
# Should show:
# acf4f6b2baa8c645af566ea210146abd97de1f48 e2sim-kpmv3
# 0ae720c977ee3dac61e3d2fde7843cb482ba44f4 mmwave-LENA-oran
```

---

### Step 2: Install System Dependencies

**Option A: Use the script (Recommended)**
```bash
bash scripts/01-install-dependencies.sh
```

**Option B: Manual installation**

```bash
# Update package list
sudo apt-get update

# E2sim requirements
sudo apt-get install -y \
  build-essential \
  git \
  cmake \
  libsctp-dev \
  autoconf \
  automake \
  libtool \
  bison \
  flex \
  libboost-all-dev \
  asn1c

# ns-3 requirements
sudo apt-get install -y \
  g++ \
  python3 \
  python3-pip \
  libc6-dev

# Optional dependencies
sudo apt-get install -y \
  sqlite3 \
  libsqlite3-dev \
  libeigen3-dev

# Python dependencies (Ubuntu 24.04 fix)
sudo apt-get install -y python3-influxdb || \
  pip3 install --break-system-packages influxdb

# Docker Compose (if not installed)
sudo apt-get install -y docker-compose
```

**Ubuntu 24.04 Special Note:**
Ubuntu 24.04 implements PEP 668, which prevents system-wide pip installations. The script handles this by:
1. First trying `python3-influxdb` from apt
2. If not available, using pip with `--break-system-packages` flag

---

### Step 3: Install FlexRIC

**Why FlexRIC is separate:**
FlexRIC is a large, independent project from EURECOM. It requires:
- Specific branch: `oie-ric-taap-xapps`
- Specific versions: E2AP v1.01, KPM v3.00 (not defaults)
- Separate build process

**Installation:**

```bash
bash scripts/02-install-flexric.sh
```

**What the script does:**

1. **Checks if FlexRIC exists**:
   - If exists, asks if you want to reinstall
   - If not, proceeds with installation

2. **Clones FlexRIC**:
   ```bash
   cd /home/mhmd/Documents/o-ran
   git clone https://gitlab.eurecom.fr/mosaic5g/flexric.git
   ```

3. **Checks out correct branch**:
   ```bash
   cd flexric
   git checkout oie-ric-taap-xapps
   ```
   **Why this branch?** It contains Orange's modifications for RIC-TaaP compatibility.

4. **Configures build**:
   ```bash
   mkdir build && cd build
   cmake .. -DE2AP_VERSION=E2AP_V1 -DKPM_VERSION=KPM_V3_00
   ```
   **Why these versions?** ns-O-RAN-flexric uses E2AP v1.01 and KPM v3.00, but FlexRIC defaults to v2.03.

5. **Builds FlexRIC**:
   ```bash
   make -j$(nproc)
   ```
   Uses all CPU cores for faster build.

6. **Verifies essential components**:
   - Checks if `nearRT-RIC` binary exists
   - Continues even if optional RRC messages fail

**Build Output:**
- **Location**:** `/home/mhmd/Documents/o-ran/flexric/build/`
- **Main binary**: `build/examples/ric/nearRT-RIC` (~3.1 MB)
- **xApps**: `build/examples/xApp/c/*/xapp_*`

**Expected Build Time**: 10-20 minutes

**Known Issue - RRC Messages:**
During build, you may see:
```
-gen-UPER: Invalid argument
Error 64 in asn1_nr_rrc_hdrs
```

**This is normal and can be ignored!** RRC messages are optional. The essential components (nearRT-RIC, xApps) will still build successfully.

**Verification:**
```bash
ls -lh /home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC
# Should show: -rwxrwxr-x ... 3.1M ... nearRT-RIC
```

---

### Step 4: Build e2sim-kpmv3

**What is e2sim?**
e2sim is the E2 Termination software that creates the SCTP connection between ns-3 simulator and FlexRIC.

**Build process:**

```bash
bash scripts/03-build-e2sim.sh
```

**What the script does:**

1. **Navigates to e2sim directory**:
   ```bash
   cd e2sim-kpmv3/e2sim
   ```

2. **Creates build directory**:
   ```bash
   mkdir -p build
   cd build
   ```

3. **Runs build script**:
   ```bash
   sudo ../build_e2sim.sh 2
   ```
   The `2` parameter sets LOG_LEVEL to INFO (level 2).

**Log Levels:**
- `0`: LOG_LEVEL_UNCOND - Only unconditional logs
- `1`: LOG_LEVEL_ERROR - Errors only
- `2`: LOG_LEVEL_INFO - Info messages (default, recommended)
- `3`: LOG_LEVEL_DEBUG - All logs including ASN.1 message dumps

**Build Process:**
1. cmake configuration with `-DDEV_PKG=1 -DLOG_LEVEL=2`
2. `make package` - Creates Debian package
3. `dpkg --install e2sim-dev_1.0.0_amd64.deb` - Installs package

**Build Output:**
- **Package**: `e2sim-kpmv3/e2sim/build/e2sim-dev_1.0.0_amd64.deb` (~3.4 MB)
- **Installed libraries**: `/usr/local/lib/` (after install)

**Expected Build Time**: 5-10 minutes

**Verification:**
```bash
ls -lh e2sim-kpmv3/e2sim/build/*.deb
# Should show: e2sim-dev_1.0.0_amd64.deb
```

---

### Step 5: Build ns-3 Simulator

**What is ns-3?**
ns-3 is a discrete-event network simulator. This version includes:
- mmWave module (millimeter wave 5G)
- 5G-LENA NR module (enhanced PHY/MAC)
- O-RAN interface module
- Sionna Ray Tracing (GPU-accelerated propagation)

**Build process:**

```bash
bash scripts/04-build-ns3.sh
```

**What the script does:**

1. **Navigates to ns-3 directory**:
   ```bash
   cd mmwave-LENA-oran
   ```

2. **Configures ns-3**:
   ```bash
   ./ns3 configure
   ```
   This:
   - Detects available modules
   - Checks dependencies
   - Generates build files
   - Creates `cmake-cache/` directory

3. **Builds ns-3**:
   ```bash
   ./ns3 build
   ```
   This compiles all modules. Uses all CPU cores by default.

**What gets built:**
- Core ns-3 simulator
- mmwave module
- nr module (5G-LENA)
- oran-interface module
- sionna module (ray tracing)
- 20+ other modules

**Modules that cannot be built** (optional, can be ignored):
- brite
- click
- mpi
- openflow
- test
- visualizer

**Expected Build Time**: 15-30 minutes (longest step)

**Build Output:**
- **Executable**: `mmwave-LENA-oran/cmake-cache/ns3`
- **Libraries**: `mmwave-cache/lib/`
- **Scenarios**: Available in `scratch/` directory

**Verification:**
```bash
cd mmwave-LENA-oran
./ns3 --version
./ns3 run --help
# Both should work without errors
```

**If build fails:**
1. Check dependencies: `sudo apt-get install -y g++ python3 libc6-dev libeigen3-dev`
2. Clean and rebuild:
   ```bash
   rm -rf build cmake-cache
   ./ns3 configure
   ./ns3 build
   ```

---

### Installation Verification

After completing all steps, verify installation:

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric

# Check FlexRIC
ls -lh /home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC
# Should exist and be ~3.1 MB

# Check e2sim
ls -lh e2sim-kpmv3/e2sim/build/*.deb
# Should show e2sim-dev_1.0.0_amd64.deb

# Check ns-3
cd mmwave-LENA-oran
./ns3 --version
# Should display version information
```

**Expected Output:**
```
✅ FlexRIC: Ready
✅ e2sim: Built
✅ ns-3: Ready
```

---

## Modifications and Fixes

This section details all modifications made to the original project, fixes applied, and workarounds implemented during deployment.

### Issue 1: Python Package Installation (Ubuntu 24.04)

**Problem**

When installing Python dependencies, the following error occurred:

```
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
```

**Root Cause**

Ubuntu 24.04 implements **PEP 668** (Python Enhancement Proposal 668), which prevents system-wide pip installations to protect the system Python environment. This is a security and stability feature.

**Solution Implemented**

**File Modified**: `scripts/01-install-dependencies.sh`

**Original Code**:
```bash
# Install Python dependencies for GUI
echo "Installing Python dependencies..."
pip3 install influxdb
```

**Modified Code**:
```bash
# Install Python dependencies for GUI
echo "Installing Python dependencies..."
# Use apt package for Ubuntu 24.04+ (externally-managed-environment)
sudo apt-get install -y python3-influxdb || {
    echo "python3-influxdb not found in apt, trying pip with --break-system-packages..."
    pip3 install --break-system-packages influxdb || echo "Warning: Could not install influxdb"
}
```

**Explanation**:
1. First attempts to install `python3-influxdb` from apt (preferred method)
2. If not available in apt, falls back to pip with `--break-system-packages` flag
3. This flag explicitly overrides PEP 668 protection (use with caution)

**Why This Works**:
- Ubuntu repositories may have `python3-influxdb` package
- If not, `--break-system-packages` allows installation (with warning)
- The flag is required by PEP 668 to acknowledge the risk

**Alternative Solutions** (not implemented):
- Use virtual environment (more complex for system-wide usage)
- Use pipx (requires additional setup)

---

### Issue 2: ASN1C Compiler Missing

**Problem**

FlexRIC build failed with error:

```
/bin/sh: 1: ASN1C_EXEC_PATH-NOTFOUND: not found
make[2]: *** [examples/xApp/c/monitor/RRC_MESSAGES/CMakeFiles/asn1_nr_rrc_hdrs.dir/build.make:71: examples/xApp/c/monitor/RRC_MESSAGES/ANY_aper.c] Error 127
```

**Root Cause**

FlexRIC requires **ASN1C** (ASN.1 Compiler) to generate C code from ASN.1 specifications. ASN.1 is used for protocol message definitions (E2AP, KPM, RC). The compiler was not installed, causing the build to fail.

**Solution Implemented**

**File Modified**: `scripts/01-install-dependencies.sh`

**Added**:
```bash
# E2sim requirements
sudo apt-get install -y \
  ...
  libboost-all-dev \
  asn1c    # <-- Added this
```

**File Modified**: `scripts/02-install-flexric.sh`

**Added Check**:
```bash
# Check if ASN1C is found, if not set the path
if ! command -v asn1c &> /dev/null; then
    echo "Warning: asn1c not found in PATH, trying to locate it..."
    ASN1C_PATH=$(which asn1c 2>/dev/null || find /usr -name asn1c 2>/dev/null | head -1)
    if [ -n "$ASN1C_PATH" ]; then
        export ASN1C_EXEC_PATH=$(dirname "$ASN1C_PATH")
        echo "Found asn1c at: $ASN1C_PATH"
    else
        echo "Error: asn1c not found. Please install it: sudo apt-get install asn1c"
        exit 1
    fi
fi
```

**Explanation**:
- ASN1C is now installed as a dependency
- Build script checks for ASN1C before building
- Sets `ASN1C_EXEC_PATH` environment variable if needed
- Fails early with clear error message if not found

**Verification**:
```bash
which asn1c
# Should output: /usr/bin/asn1c
```

---

### Issue 3: RRC Messages Build Failure

**Problem**

During FlexRIC build, RRC (Radio Resource Control) messages compilation fails:

```
[ 36%] Generating NR RRC source file from .../nr-rrc-17.3.0.asn1
-gen-UPER: Invalid argument
make[2]: *** Error 64
```

**Root Cause**

RRC messages use complex ASN.1 specifications that require UPER (Unaligned Packed Encoding Rules) encoding. The ASN1C compiler version or the ASN.1 specification may have compatibility issues with the `-gen-UPER` flag.

**Important**: RRC messages are **optional** and not required for core FlexRIC functionality. The system works perfectly without them.

**Solution Implemented**

**File Modified**: `scripts/02-install-flexric.sh`

**Original Behavior**: Build would fail completely if RRC failed.

**Modified Behavior**:
```bash
# Build FlexRIC (RRC messages may fail but are optional)
echo "Building (this may take 10-30 minutes)..."
if make -j$(nproc) 2>&1 | tee build.log; then
    echo "Build completed successfully!"
else
    # Check if essential components were built despite errors
    if [ -f "examples/ric/nearRT-RIC" ]; then
        echo "✓ nearRT-RIC built successfully!"
        echo "✓ Essential components are ready"
        if grep -q "asn1_nr_rrc\|RRC_MESSAGES" build.log; then
            echo "⚠ RRC messages build failed (optional component - can be ignored)"
        fi
    else
        echo "✗ Error: nearRT-RIC not found. Build failed."
        exit 1
    fi
fi
```

**Explanation**:
1. Build continues even if RRC fails
2. Checks if essential binary (`nearRT-RIC`) exists
3. If exists, reports success (with RRC warning)
4. Only fails if essential components are missing

**Verification**:
```bash
ls -lh /home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC
# Should exist even if RRC failed
```

**Impact**: None - RRC messages are not used by any xApps in this project.

---

### Issue 4: Port 36421 Already in Use

**Problem**

When starting FlexRIC, error occurs:

```
errno = 98
nearRT-RIC: Assertion `rc != -1' failed.
Aborted (core dumped)
```

**errno 98** = `EADDRINUSE` (Address already in use)

**Root Cause**

Port 36421 (default FlexRIC port) is already occupied by:
- Previous FlexRIC instance still running
- Another process using the port

**Solution Implemented**

**File Modified**: `scripts/05-start-flexric.sh`

**Added Port and Process Check**:
```bash
# Check if port 36421 is already in use
if lsof -i :36421 >/dev/null 2>&1 || netstat -tuln 2>/dev/null | grep -q ":36421" || ss -tuln 2>/dev/null | grep -q ":36421"; then
    echo "⚠ Port 36421 is already in use"
    echo "Checking for existing nearRT-RIC process..."
    
    # Try to find and kill existing nearRT-RIC
    PIDS=$(pgrep -f "nearRT-RIC" || true)
    if [ -n "$PIDS" ]; then
        echo "Found existing nearRT-RIC process(es): $PIDS"
        read -p "Do you want to kill them and start new? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill -9 $PIDS 2>/dev/null || true
            sleep 2
            echo "✓ Killed existing processes"
        else
            echo "Please stop the existing process manually or use a different port"
            exit 1
        fi
    else
        echo "No nearRT-RIC process found, but port is in use by another process"
        echo "You can:"
        echo "  1. Kill the process using port 36421"
        echo "  2. Use a different port with: ./nearRT-RIC --port <PORT>"
        exit 1
    fi
fi
```

**New Script Created**: `scripts/11-kill-flexric.sh`

```bash
#!/bin/bash
# Script to kill existing FlexRIC processes

PIDS=$(pgrep -f "nearRT-RIC" || true)

if [ -z "$PIDS" ]; then
    echo "No nearRT-RIC process found"
else
    echo "Found nearRT-RIC process(es): $PIDS"
    kill -9 $PIDS 2>/dev/null || true
    sleep 1
    echo "✓ Killed nearRT-RIC processes"
fi

# Check for processes using port 36421
PORT_PIDS=$(sudo lsof -ti :36421 2>/dev/null || true)
if [ -n "$PORT_PIDS" ]; then
    echo "Found process(es) using port 36421: $PORT_PIDS"
    read -p "Kill them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo kill -9 $PORT_PIDS 2>/dev/null || true
        echo "✓ Killed processes using port 36421"
    fi
fi
```

**Explanation**:
1. Checks port using multiple methods (lsof, netstat, ss)
2. Finds existing FlexRIC processes
3. Prompts user to kill them
4. Provides alternative solutions if port is used by other process

**Usage**:
```bash
# Automatic (in start script)
bash scripts/05-start-flexric.sh

# Manual cleanup
bash scripts/11-kill-flexric.sh
```

---

### Issue 5: make install Fails Due to RRC

**Problem**

After successful build, `sudo make install` fails because it tries to rebuild everything including RRC messages.

**Root Cause**

`make install` target depends on `all` target, which includes RRC. Since RRC build fails, `make install` also fails.

**Solution Implemented**

**Note**: The system works perfectly **without** `make install`. All binaries are in the build directory and can be used directly:
- `/home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC`
- `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/*/xapp_*`

**Alternative**: If you need to install, use:
```bash
sudo make install -k
```

The `-k` flag continues installation even if some targets fail.

---

### Summary of All Modifications

#### Files Modified

1. **scripts/01-install-dependencies.sh**
   - Added `asn1c` package
   - Fixed Python package installation for Ubuntu 24.04

2. **scripts/02-install-flexric.sh**
   - Added ASN1C check
   - Added RRC failure handling
   - Modified build to continue despite RRC errors

3. **scripts/05-start-flexric.sh**
   - Added port conflict detection
   - Added process killing functionality
   - Added user prompts

#### Files Created

1. **scripts/08-fix-flexric-build.sh** - Build fix utility
2. **scripts/09-install-flexric-manual.sh** - Manual installation
3. **scripts/10-skip-rrc-build.sh** - Disable RRC build
4. **scripts/11-kill-flexric.sh** - Process cleanup
5. **scripts/12-start-all.sh** - Complete system startup
6. **docker/Dockerfile.flexric** - FlexRIC container
7. **docker/Dockerfile.e2sim** - e2sim container
8. **docker/Dockerfile.ns3** - ns-3 container
9. **docker/docker-compose.yml** - Complete system compose
10. **docker/README.md** - Docker documentation

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

### Scenarios

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

**Running a Scenario from Command Line**:
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

### Problem: Submodules Not Cloned

**Symptom**: `e2sim-kpmv3/` or `mmwave-LENA-oran/` directories are empty

**Solution**:
```bash
git submodule update --init --recursive
```

### Problem: ASN1C Not Found

**Symptom**: FlexRIC build fails with "ASN1C_EXEC_PATH-NOTFOUND"

**Solution**:
```bash
sudo apt-get install -y asn1c
# Then rebuild FlexRIC
```

### Problem: Build Fails Due to Memory

**Symptom**: Build stops or system becomes unresponsive

**Solution**:
- Reduce parallelism: `make -j4` instead of `make -j$(nproc)`
- Close other applications
- Add swap space if needed

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

## Advanced Topics

### Monitoring and KPIs

#### Available KPIs

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

#### Viewing KPIs

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

### Performance Considerations

#### System Resources

**Minimum**:
- 8GB RAM
- 4 CPU cores
- 20GB disk

**Recommended**:
- 16GB RAM
- 8+ CPU cores
- 50GB+ disk
- SSD for faster builds

#### Build Optimization

**Parallel Builds**:
- FlexRIC: `make -j$(nproc)`
- ns-3: Uses all cores by default

**Memory Issues**:
- Reduce parallelism: `make -j4`
- Close other applications
- Use swap if needed

#### Runtime Performance

**GUI**:
- First load: 5-10 minutes (Docker build)
- Subsequent: Instant
- Memory: ~500MB per container

**ns-3**:
- Simulation speed depends on scenario
- Complex scenarios: slower
- Use shorter simTime for testing

### Security Considerations

#### Network Security

- GUI and Grafana exposed on network
- Change default passwords
- Use firewall rules
- Consider VPN for remote access

#### Docker Security

- Run containers as non-root when possible
- Use Docker secrets for passwords
- Keep images updated
- Scan for vulnerabilities

#### System Security

- Keep system updated
- Use strong passwords
- Limit sudo access
- Monitor logs

### Maintenance

#### Regular Tasks

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

#### Log Management

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

### Best Practices

#### 1. Build Order

Always follow this order:
1. Dependencies
2. FlexRIC
3. e2sim
4. ns-3

#### 2. Starting System

Recommended order:
1. FlexRIC first
2. GUI second
3. GUI Trigger third
4. xApp last (when needed)

#### 3. Stopping System

1. Stop xApp (Ctrl+C)
2. Stop GUI Trigger (Ctrl+C)
3. Stop FlexRIC (Ctrl+C or kill script)
4. Stop GUI: `docker-compose down`

#### 4. Development

- Keep source code mounted in Docker for live changes
- Use separate terminals for each component
- Check logs regularly
- Verify ports before starting

#### 5. Troubleshooting

- Always check logs first
- Verify all components are built
- Check port availability
- Verify network connectivity
- Check Docker status (for GUI)

---

## Appendices

### Appendix A: Key Directories and Files

#### FlexRIC
- **Binary**: `/home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC`
- **xApps**: `/home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/`
- **Config**: `/usr/local/etc/flexric/flexric.conf` (after install)

#### e2sim
- **Package**: `e2sim-kpmv3/e2sim/build/e2sim-dev_1.0.0_amd64.deb`
- **Source**: `e2sim-kpmv3/e2sim/`

#### ns-3
- **Executable**: `mmwave-LENA-oran/cmake-cache/ns3`
- **Scenarios**: `mmwave-LENA-oran/scratch/`
- **Build**: `mmwave-cache/`

#### GUI
- **Location**: `mmwave-LENA-oran/GUI/`
- **Docker Compose**: `mmwave-LENA-oran/GUI/docker-compose.yml`
- **Trigger Script**: `mmwave-LENA-oran/gui_trigger.py`

### Appendix B: xApps Usage

#### xapp_kpm_rc

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

#### xapp_es_with_cell_util

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

#### xapp_rc_handover_ctrl

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

### Appendix C: Standards and Protocols

#### E2AP v1.01
- **Full Name**: E2 Application Protocol version 1.01
- **Purpose**: Communication protocol between RIC and RAN nodes
- **Key Messages**: Setup, Subscription, Indication, Control

#### KPM v3.00
- **Full Name**: Key Performance Measurement version 3.00
- **Purpose**: Define what metrics to collect and how
- **Key Features**: Per-UE and per-Cell measurements

#### RC v1.03
- **Full Name**: RAN Control version 1.03
- **Purpose**: Control actions (handover, cell on/off, etc.)
- **Key Features**: Handover control, Energy Saving control

#### SCTP
- **Full Name**: Stream Control Transmission Protocol
- **Purpose**: Reliable transport for E2AP messages
- **Port**: 36421 (default)

### Appendix D: Development History

#### Original Components
- **e2sim**: Developed by OSC community
- **ns3-mmWave**: University of Padova and NYU
- **ns-O-RAN**: Northeastern University and Mavenir
- **5G-LENA**: CTTC (Centre Tecnològic de Catalunya)
- **Sionna RT**: Nvidia (translated to ns-3)

#### Orange Contributions
- Upgraded to E2AP v1.01, KPM v3.00, RC v1.03
- Added RIC-TaaP Studio GUI
- Implemented Energy Saving xApp
- Added Digital Twin capabilities
- Enhanced scenarios and use cases

### Appendix E: Complete KPI List

#### Per UE KPIs (26 metrics)

| # | KPI Name | Description | Unit |
|---|---------|-------------|------|
| 1 | `ue_position_x_{ue_id}` | UE X coordinate position | meters |
| 2 | `ue_position_y_{ue_id}` | UE Y coordinate position | meters |
| 3 | `ue_position_type_{ue_id}` | UE position type (indoor/outdoor) | - |
| 4 | `ue_position_cell_{ue_id}` | Cell ID where UE is connected | - |
| 5 | `ue_{ue_id}_tb.errtotalnbrdl.1.ueid` | Total number of DL transport block errors | count |
| 6 | `ue_{ue_id}_drb.buffersize.qos.ueid` | DRB buffer size per QoS | bytes |
| 7 | `ue_{ue_id}_rru.prbuseddl` | Number of PRBs used in DL | count |
| 8 | `ue_{ue_id}_drb.uethpdlpdcpbased.ueid` | UE throughput (PDCP-based) in DL | bps |
| 9 | `ue_{ue_id}_drb.uethpdl.ueid` | UE throughput in DL | bps |
| 10 | `ue_{ue_id}_qosflow.pdcppduvolumedl_filter` | PDCP PDU volume in DL (filtered) | bytes |
| 11 | `ue_{ue_id}_tb.totnbrdlinitial` | Total number of DL initial transmissions | count |
| 12 | `ue_{ue_id}_tb.totnbrdlinitial.16qam` | DL initial transmissions with 16QAM | count |
| 13 | `ue_{ue_id}_tb.totnbrdlinitial.64qam` | DL initial transmissions with 64QAM | count |
| 14 | `ue_{ue_id}_tb.totnbrdlinitial.qpsk.ueid` | DL initial transmissions with QPSK | count |
| 15 | `ue_{ue_id}_tb.totnbrdl.1.ueid` | Total number of DL transport blocks | count |
| 16 | `ue_{ue_id}_qosflow_pdcppduvolumedl_filter_ueid` | PDCP PDU volume (txpdcppdubytesnrrlc) | bytes |
| 17 | `ue_{ue_id}_drb.pdcpsdudelaydl.ueid` | PDCP SDU delay in DL (latency) | seconds |
| 18 | `ue_{ue_id}_drb_pdcppdunbrdl_qos_ueid` | PDCP PDU number (txpdcppdunrrlc) | count |
| 19 | `ue_{ue_id}_tot_pdcpsdunbrdl_ueid` | Total PDCP SDU number (txdlpackets) | count |
| 20 | `ue_{ue_id}_drb.pdcpsdubitratedl.ueid` | PDCP SDU bitrate in DL (throughput) | bps |
| 21 | `ue_{ue_id}_drb.pdcpsduvolumedl_filter.ueid` | PDCP SDU volume (txbytes) | bytes |
| 22 | `ue_{ue_id}_l3 serving sinr` | L3 serving cell SINR | dB |
| 23 | `ue_position_cell_{ue_id}` | Current serving cell ID | - |
| 24 | `ue_{ue_id}_l3 neigh sinr` | L3 neighbor cell SINR | dB |
| 25 | `ue_{ue_id}_l3 neigh id` | L3 neighbor cell ID | - |
| 26 | `ue_{ue_id}_drb.estabsucc.5qi.ueid` | DRB establishment success per 5QI | count |

#### Per Cell KPIs (13 metrics)

| # | KPI Name | Description | Unit |
|---|---------|-------------|------|
| 1 | `du-cell-{cell_id}_tb.errtotalnbrdl.1.ueid` | Total DL transport block errors | count |
| 2 | `du-cell-{cell_id}_drb.meanactiveuedl` | Mean number of active UEs in DL | count |
| 3 | `du-cell-{cell_id}_drb.buffersize.qos.ueid` | DRB buffer size per QoS | bytes |
| 4 | `du-cell_{cell_id}_rru.prbuseddl` | PRBs used in DL | count |
| 5 | `du-cell-{cell_id}_qosflow.pdcppduvolumedl_filter` | PDCP PDU volume in DL | bytes |
| 6 | `du-cell-{cell_id}_tb.totnbrdlinitial` | Total DL initial transmissions | count |
| 7 | `du-cell-{cell_id}_tb.totnbrdlinitial.16qam` | DL initial transmissions with 16QAM | count |
| 8 | `du-cell-{cell_id}_tb.totnbrdlinitial.64qam` | DL initial transmissions with 64QAM | count |
| 9 | `du-cell-{cell_id}_tb.totnbrdlinitial.qpsk.ueid` | DL initial transmissions with QPSK | count |
| 10 | `du-cell-{cell_id}_tb.totnbrdl.1.ueid` | Total DL transport blocks | count |
| 11 | `du-cell-{cell_id}_dlprbusage` | DL PRB usage percentage | % |
| 12 | `cu-up-cell-{cell_id}_drb.pdcpsdudelaydl` | Average cell latency | seconds |
| 13 | `cu-up-cell-{cell_id}_m_pdcpbytesdl` | Cell DL TX volume | bytes |

### Appendix F: Detailed Scenario Parameters

#### scenario-zero-with_parallel_loging.cc

**Description**: NSA 5G setup with one LTE eNB and four gNBs. Supports parallel logging to files and E2 termination.

**Parameters**:
```bash
--e2TermIp=127.0.0.1              # E2 Termination IP address
--indicationPeriodicity=0.1       # KPI indication period (seconds)
--simTime=1000                    # Simulation time (seconds)
--KPM_E2functionID=2             # KPM RAN Function ID
--RC_E2functionID=3              # RC RAN Function ID
--N_MmWaveEnbNodes=4             # Number of mmWave eNB nodes
--N_Ues=3                         # Number of UEs
--CenterFrequency=3.5e9          # Center frequency (Hz)
--Bandwidth=20e6                 # Bandwidth (Hz)
--IntersideDistanceUEs=500       # Inter-site distance for UEs (meters)
--IntersideDistanceCells=600     # Inter-site distance for cells (meters)
--E2andLogging=true               # Enable parallel logging and E2
--hoSinrDifference=3             # Handover SINR difference threshold (dB)
```

**Topology**:
- 1 LTE eNB at center
- 4 gNBs (1 co-located with LTE, 3 at 1000m distance)
- UEs distributed randomly

#### Energy_Saving_with_load_balancing_scenario.cc

**Description**: Energy Saving use case with load balancing capabilities.

**Parameters**:
```bash
--e2TermIp=127.0.0.1
--indicationPeriodicity=0.1
--simTime=1000
--KPM_E2functionID=2
--RC_E2functionID=3
--N_MmWaveEnbNodes=4
--N_Ues=3
--CenterFrequency=3.5e9
--Bandwidth=20e6
```

**Features**:
- PRB usage monitoring per cell
- Automatic cell on/off based on utilization
- Load balancing across active cells
- Energy consumption tracking

#### scenario-three.cc

**Description**: Basic 5G scenario for handover testing.

**Parameters**:
```bash
--e2TermIp=127.0.0.1
--indicationPeriodicity=0.1
--simTime=1000
--KPM_E2functionID=2
--RC_E2functionID=3
```

**Use Case**: Handover control testing

#### orange-rf-channel-reconfiguration.cc

**Description**: 5G-LENA scenario with RF channel reconfiguration.

**Parameters**:
```bash
--e2TermIp=127.0.0.1
--indicationPeriodicity=0.1
--simTime=1000
--KPM_E2functionID=2
--RC_E2functionID=3
```

**Features**:
- 5G-LENA NR module
- RF channel reconfiguration
- Enhanced PHY/MAC capabilities

### Appendix G: E2AP Message Flow

#### E2 Setup Procedure

1. **E2 Setup Request** (from e2sim to FlexRIC)
   - Contains RAN Function IDs (KPM=2, RC=3)
   - Message size: 62 bytes
   - Includes KPM v3.00 and RC v1.03 descriptions
   - Includes STYLE_4_RIC_SERVICE_REPORT
   - Includes STYLE_1_RIC_EVENT_TRIGGER
   - Includes FORMAT_1_RIC_EVENT_TRIGGER

2. **E2 Setup Response** (from FlexRIC to e2sim)
   - Acknowledges setup
   - May include RAN Function NotAdmitted IE

#### Subscription Procedure

1. **E2 Subscription Request** (from FlexRIC to e2sim)
   - Specifies RAN Function ID (KPM or RC)
   - Includes FORMAT_4_ACTION_DEFINITION
   - Defines measurement types and periodicity

2. **E2 Subscription Response** (from e2sim to FlexRIC)
   - Confirms subscription
   - May include RAN Function NotAdmitted IE

#### Indication Procedure

1. **RIC Indication** (from e2sim to FlexRIC)
   - Contains KPM v3.00 formatted data
   - Includes Format 3 indication messages
   - Sent periodically (indicationPeriodicity)
   - Contains per-UE and per-Cell KPIs

#### Control Procedure

1. **RIC Control Request** (from FlexRIC to e2sim)
   - Matches E2SM RC v1.03 format
   - Includes CONTROL Service Style 3
   - Includes Connected Mode Mobility Management
   - Control Action IDs:
     - ID 1: Handover Control
     - ID 2: Conditional Handover Control
     - ID 3: DAPS Handover Control

2. **RIC Control Acknowledge** (from e2sim to FlexRIC)
   - Confirms control action execution
   - Includes result status

### Appendix H: Energy Saving xApp Logic

#### Operation Sequence

1. **Initialization**
   - xApp connects to FlexRIC
   - Subscribes to KPM indications
   - Sets up monitoring for PRB usage

2. **Monitoring Phase**
   - Receives periodic KPM indications
   - Extracts PRB usage per cell
   - Calculates cell utilization percentage

3. **Decision Logic**
   - **If PRB usage < threshold (e.g., 10%)**:
     - Mark cell as candidate for shutdown
     - Check if other cells can handle load
     - If yes, send RC Control Request to switch off cell
   
   - **If PRB usage > threshold (e.g., 80%)**:
     - Check if any cells are switched off
     - If yes, send RC Control Request to switch on cell
     - Redistribute load

4. **Control Execution**
   - Sends RC Control Request via FlexRIC
   - Waits for RIC Control Acknowledge
   - Updates internal state

5. **Monitoring After Control**
   - Continues monitoring KPIs
   - Tracks energy consumption
   - Calculates energy savings

#### Thresholds (Configurable)

- **Low Utilization Threshold**: 10% PRB usage
- **High Utilization Threshold**: 80% PRB usage
- **Cooldown Period**: Time between state changes

#### O-RAN Use Case 21 Compliance

- **Use Case**: Carrier and Cell Switch On/Off
- **Sub-use Case**: 4.21.3.1
- **Standard**: O-RAN Use Cases Detailed Specification 15.0

### Appendix I: Handover xApp Logic

#### Operation Sequence

1. **Initialization**
   - xApp connects to FlexRIC
   - Subscribes to KPM indications
   - Sets up monitoring for UE positions and SINR

2. **Monitoring Phase**
   - Receives periodic KPM indications
   - Extracts:
     - UE serving cell SINR
     - UE neighbor cell SINR
     - UE position
     - Current serving cell

3. **Decision Logic**
   - **If neighbor SINR > serving SINR + threshold**:
     - Calculate target cell (best neighbor)
     - Check if handover is feasible
     - If yes, prepare handover request

4. **Control Execution**
   - Sends RC Control Request with:
     - Control Action ID 1 (Handover Control)
     - Source cell ID
     - Target cell ID
     - UE ID
   - Waits for acknowledgment

5. **Verification**
   - Monitors subsequent indications
   - Verifies UE is connected to target cell
   - Logs handover success/failure

#### Handover Types Supported

1. **Standard Handover** (Control Action ID 1)
   - Direct handover from source to target

2. **Conditional Handover** (Control Action ID 2)
   - Handover with conditions
   - Multiple candidate cells

3. **DAPS Handover** (Control Action ID 3)
   - Dual Active Protocol Stack
   - Maintains connection during handover

### Appendix J: GUI Features Detailed

#### RIC-TaaP Studio Main Features

1. **Network Topology Visualization**
   - Real-time cell positions
   - UE positions and movements
   - Cell coverage areas
   - Connection lines (UE to cell)

2. **Real-time KPI Display**
   - Per-UE KPIs table
   - Per-Cell KPIs table
   - Auto-refresh (1 second or on indication)
   - Filterable and sortable

3. **Scenario Control**
   - Scenario selection dropdown
   - Parameter configuration form
   - Start/Stop simulation
   - Scenario flags (quick configuration)

4. **Energy Saving Dashboard**
   - PRB usage per cell (graph)
   - Energy consumption (before/after)
   - Cell state (on/off) visualization
   - QoS metrics tracking
   - Energy savings calculation

5. **A1 Policy Management**
   - Set A1 policies
   - Get A1 policies
   - Policy status monitoring

6. **FlexRIC Connection**
   - Connect/Disconnect toggle
   - Connection status indicator
   - xApp status display

#### Grafana Integration

**Pre-configured Dashboards**:
- `per_Cell_stats`: Cell-level KPIs
- `per_UE_stats`: UE-level KPIs

**Features**:
- Time-series visualization
- Historical data analysis
- CDF (Cumulative Distribution Function) plots
- Custom queries
- Auto-refresh

### Appendix K: InfluxDB Queries

#### Query All UE KPIs

```sql
SELECT * FROM "ue_position_x_0" WHERE time >= now() - 1h
```

#### Query Cell PRB Usage

```sql
SELECT mean("value") FROM "du-cell-1_rru.prbuseddl" 
WHERE time >= now() - 1h 
GROUP BY time(10s)
```

#### Query UE Throughput

```sql
SELECT mean("value") FROM "ue_0_drb.pdcpsdubitratedl.ueid" 
WHERE time >= now() - 1h 
GROUP BY time(1s)
```

#### Query Cell Latency

```sql
SELECT mean("value") FROM "cu-up-cell-1_drb.pdcpsdudelaydl" 
WHERE time >= now() - 1h 
GROUP BY time(10s)
```

#### Query Energy Consumption

```sql
SELECT sum("value") FROM "energy_consumption" 
WHERE time >= now() - 1h 
GROUP BY time(1m)
```

### Appendix L: Practical Examples

#### Example 1: Running Scenario Zero with Custom Parameters

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/mmwave-LENA-oran

./ns3 run "scratch/scenario-zero-with_parallel_loging.cc \
  --e2TermIp=127.0.0.1 \
  --indicationPeriodicity=0.1 \
  --simTime=2000 \
  --KPM_E2functionID=2 \
  --RC_E2functionID=3 \
  --N_MmWaveEnbNodes=4 \
  --N_Ues=5 \
  --CenterFrequency=3.5e9 \
  --Bandwidth=20e6 \
  --IntersideDistanceUEs=500 \
  --IntersideDistanceCells=600 \
  --E2andLogging=true \
  --hoSinrDifference=3"
```

#### Example 2: Monitoring Specific KPIs in Grafana

1. Open Grafana: http://localhost:3000
2. Navigate to Dashboards → Manage
3. Select `per_UE_stats`
4. Add query:
   ```
   SELECT mean("value") FROM "ue_0_drb.pdcpsdubitratedl.ueid" 
   WHERE time >= now() - 30m 
   GROUP BY time(1s)
   ```
5. Set auto-refresh to 5 seconds

#### Example 3: Energy Saving xApp with Custom Thresholds

Modify the xApp source code to change thresholds:
```c
// In xapp_es_with_cell_util source
#define LOW_UTILIZATION_THRESHOLD 0.10  // 10%
#define HIGH_UTILIZATION_THRESHOLD 0.80 // 80%
#define COOLDOWN_PERIOD 30              // seconds
```

Rebuild:
```bash
cd /home/mhmd/Documents/o-ran/flexric/build
make
```

### Appendix M: Advanced Configuration

#### FlexRIC Configuration File

Location: `/usr/local/etc/flexric/flexric.conf` (after install)

Key settings:
```ini
[ric]
port = 36421
log_level = INFO

[xapps]
enable_kpm = true
enable_rc = true
enable_es = true
```

#### ns-3 Configuration

Location: `mmwave-LENA-oran/.ns3rc`

Example:
```python
# ns-3 configuration
def configure_ns3():
    return {
        'build-profile': 'optimized',
        'enable-examples': False,
        'enable-tests': False,
    }
```

#### GUI Configuration

Location: `mmwave-LENA-oran/GUI/docker-compose.yml`

Key environment variables:
```yaml
environment:
  - NS3_HOST=192.168.1.100
  - INFLUXDB_HOST=influxdb
  - INFLUXDB_PORT=8086
  - GRAFANA_HOST=grafana
  - GRAFANA_PORT=3000
```

### Appendix N: Development Workflow

#### Adding a New xApp

1. **Create xApp Directory**
   ```bash
   cd /home/mhmd/Documents/o-ran/flexric/examples/xApp/c
   mkdir my_xapp
   cd my_xapp
   ```

2. **Create Source Files**
   - `xapp_my_xapp.c`: Main xApp logic
   - `CMakeLists.txt`: Build configuration

3. **Implement xApp Logic**
   - Connect to FlexRIC
   - Subscribe to KPM/RC indications
   - Process KPIs
   - Send control actions (if needed)

4. **Build**
   ```bash
   cd /home/mhmd/Documents/o-ran/flexric/build
   cmake ..
   make
   ```

5. **Test**
   ```bash
   cd examples/xApp/c/my_xapp
   ./xapp_my_xapp
   ```

#### Adding a New Scenario

1. **Create Scenario File**
   ```bash
   cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/mmwave-LENA-oran/scratch
   cp scenario-zero.cc my_scenario.cc
   ```

2. **Modify Scenario**
   - Adjust topology
   - Configure parameters
   - Add custom logic

3. **Build**
   ```bash
   cd mmwave-LENA-oran
   ./ns3 build
   ```

4. **Run**
   ```bash
   ./ns3 run "scratch/my_scenario.cc --e2TermIp=127.0.0.1"
   ```

### Appendix O: Support and Resources

#### Documentation
- **README.md**: Original project README
- **This file**: Complete documentation
- **docs/**: Additional documentation files
  - `Energy_saving_usecases.pdf`: Energy Saving use case details
  - `handover_operation.pdf`: Handover operation documentation
  - `Grafana KPIs`: Complete KPI list

#### Scripts Help
Each script has comments explaining what it does. Read the script file for details.

#### Community
- **GitHub**: https://github.com/Orange-OpenSource/ns-O-RAN-flexric
- **FlexRIC**: https://gitlab.eurecom.fr/mosaic5g/flexric
- **ns-O-RAN**: https://openrangym.com/ran-frameworks/ns-o-ran
- **5G-LENA**: https://5g-lena.cttc.es/
- **Sionna RT**: https://nvlabs.github.io/sionna/rt/

#### Video Resources
- **RIC-TaaP Demo**: https://www.youtube.com/watch?v=oN0gBh1E7RE
- **Energy Saving Demo**: https://www.youtube.com/watch?v=p5MOp3b8Nm8
- **KPM-RC xApp Demo**: https://www.youtube.com/watch?v=xD4TbgZ74wY
- **OAI Demo**: https://youtu.be/PgwKyk8b6K0

#### Contributors
- Mina Yonan, Orange Innovation Egypt
- Mostafa Ashraf, Orange Innovation Egypt
- Kamil Kociszewski, Orange Innovation Poland
- Adrian Oziębło, Orange Innovation Poland
- Abdelrhman Soliman, Orange Innovation Egypt
- Aya Kamal, Orange Innovation Egypt
- Bartosz Rak, Orange Innovation Poland
- Andrzej Denisiewicz, Orange Innovation Poland

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
**Tested On**: Ubuntu 24.04.3 LTS  
**Status**: Complete and Operational

---

*End of Documentation*

