# Complete Installation Guide

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

---

## Installation Methods

### Method 1: Automated Installation (Recommended)

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

### Method 2: Step-by-Step Installation

**For understanding each step or troubleshooting:**

Follow the detailed steps below.

---

## Detailed Installation Steps

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

**What each package does:**

- **build-essential**: GCC compiler, make, and other build tools
- **cmake**: Build system generator
- **libsctp-dev**: SCTP protocol library (for E2AP)
- **autoconf, automake, libtool**: Build configuration tools
- **bison, flex**: Parser generators (for ASN.1)
- **libboost-all-dev**: C++ libraries
- **asn1c**: ASN.1 compiler (for FlexRIC)
- **g++**: C++ compiler
- **python3**: Python interpreter
- **libeigen3-dev**: Linear algebra library (for MIMO)
- **python3-influxdb**: Python client for InfluxDB

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

6. **Installs Service Models**:
   ```bash
   sudo make install -k
   ```
   `-k` flag continues even if optional components (like RRC) fail.

**Build Output:**
- **Location**: `/home/mhmd/Documents/o-ran/flexric/build/`
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

## Installation Verification

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

## Common Installation Issues

### Issue 1: Submodules Not Cloned

**Symptom**: `e2sim-kpmv3/` or `mmwave-LENA-oran/` directories are empty

**Solution**:
```bash
git submodule update --init --recursive
```

### Issue 2: ASN1C Not Found

**Symptom**: FlexRIC build fails with "ASN1C_EXEC_PATH-NOTFOUND"

**Solution**:
```bash
sudo apt-get install -y asn1c
# Then rebuild FlexRIC
```

### Issue 3: Python Package Installation Fails (Ubuntu 24.04)

**Symptom**: `externally-managed-environment` error

**Solution**:
```bash
sudo apt-get install -y python3-influxdb
# OR
pip3 install --break-system-packages influxdb
```

### Issue 4: Build Fails Due to Memory

**Symptom**: Build stops or system becomes unresponsive

**Solution**:
- Reduce parallelism: `make -j4` instead of `make -j$(nproc)`
- Close other applications
- Add swap space if needed

### Issue 5: Port Already in Use

**Symptom**: FlexRIC fails to start

**Solution**:
```bash
bash scripts/11-kill-flexric.sh
```

---

## Next Steps

After successful installation:

1. **Start the system**: See "Running the System" section
2. **Access GUI**: http://YOUR_IP:8000
3. **Run scenarios**: Select from GUI or command line
4. **Monitor KPIs**: View in GUI or Grafana

---

**Installation Complete!** All components are built and ready to use.

