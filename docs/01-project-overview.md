# Project Overview and Repository Structure

## What is ns-O-RAN-flexric?

**ns-O-RAN-flexric** is an open-source framework designed for comprehensive testing of xApps and rApps in 5G networks. It is an integral component of the **RIC Testing as a Platform (RIC-TaaP)** project developed by Orange Innovation Egypt (OIE) and Orange Innovation Poland (OIP).

### Purpose

The project provides:
- **Comprehensive 5G System-Level Environment**: Full 5G/LTE simulation environment for RIC testing
- **Digital Twin Testing**: Verify and calibrate use cases using real KPIs from operational 5G environments
- **User-Friendly GUI**: RIC-TaaP Studio with intuitive dashboards and operational features
- **AI Integration Ready**: Framework designed to support LLM-powered algorithms and Agentic-AI for RAN optimization

### Repository Information

- **GitHub**: https://github.com/Orange-OpenSource/ns-O-RAN-flexric
- **License**: GNU General Public License v2
- **Maintainers**: Orange Innovation Egypt & Orange Innovation Poland
- **Status**: Active development

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

---

## Core Components Explained

### 1. FlexRIC (External Dependency)

**What it is**: RAN Intelligent Controller - the brain of the O-RAN system

**Location**: `/home/mhmd/Documents/o-ran/flexric/` (installed separately)

**Purpose**:
- Manages E2 connections with RAN nodes
- Hosts xApps and rApps
- Processes KPM indications
- Sends RC control messages

**Key Files**:
- `build/examples/ric/nearRT-RIC` - Main RIC binary
- `build/examples/xApp/c/` - Various xApps

**Why Separate**: FlexRIC is a large, independent project from EURECOM. It must be built with specific configurations (E2AP v1.01, KPM v3.00) that differ from defaults.

### 2. e2sim-kpmv3 (Git Submodule)

**What it is**: E2 Termination software - creates SCTP connection between ns-3 and RIC

**Location**: `e2sim-kpmv3/e2sim/`

**Purpose**:
- Implements E2AP v1.01 protocol
- Implements KPM v3.00
- Translates between ns-3 and RIC
- Handles message encoding/decoding

**Build Output**: Debian package `e2sim-dev_1.0.0_amd64.deb`

### 3. mmwave-LENA-oran (Git Submodule)

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

### 4. RIC-TaaP Studio (GUI)

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

### 5. Supporting Services

**InfluxDB**: Time-series database storing KPIs
- Port: 8086
- Purpose: Store historical KPI data

**Grafana**: Visualization platform
- Port: 3000
- Purpose: Create dashboards and analyze historical data

---

## Standards and Protocols

### E2AP v1.01
- **Full Name**: E2 Application Protocol version 1.01
- **Purpose**: Communication protocol between RIC and RAN nodes
- **Key Messages**: Setup, Subscription, Indication, Control

### KPM v3.00
- **Full Name**: Key Performance Measurement version 3.00
- **Purpose**: Define what metrics to collect and how
- **Key Features**: Per-UE and per-Cell measurements

### RC v1.03
- **Full Name**: RAN Control version 1.03
- **Purpose**: Control actions (handover, cell on/off, etc.)
- **Key Features**: Handover control, Energy Saving control

### SCTP
- **Full Name**: Stream Control Transmission Protocol
- **Purpose**: Reliable transport for E2AP messages
- **Port**: 36421 (default)

---

## Use Cases Supported

### 1. KPM Monitoring
- Collect KPIs from simulated network
- Display in GUI and Grafana
- Support for 26+ metrics per UE

### 2. Handover Control
- Initiate handover requests
- Control UE mobility
- Monitor handover success

### 3. Energy Saving
- Monitor cell utilization (PRB usage)
- Automatically switch cells on/off
- O-RAN Use Case 21 implementation

### 4. Load Balancing
- Distribute load across cells
- Optimize resource utilization
- Improve QoS

---

## Development History

### Original Components
- **e2sim**: Developed by OSC community
- **ns3-mmWave**: University of Padova and NYU
- **ns-O-RAN**: Northeastern University and Mavenir
- **5G-LENA**: CTTC (Centre Tecnològic de Catalunya)
- **Sionna RT**: Nvidia (translated to ns-3)

### Orange Contributions
- Upgraded to E2AP v1.01, KPM v3.00, RC v1.03
- Added RIC-TaaP Studio GUI
- Implemented Energy Saving xApp
- Added Digital Twin capabilities
- Enhanced scenarios and use cases

---

## Key Features

### 1. Real-time Monitoring
- Live KPI updates
- Network topology visualization
- Cell and UE tracking

### 2. Scenario Management
- Pre-built scenarios
- Customizable parameters
- Scenario flags for quick setup

### 3. xApp Integration
- Easy xApp deployment
- GUI-based xApp control
- Real-time xApp monitoring

### 4. Historical Analysis
- Grafana dashboards
- InfluxDB storage
- CDF (Cumulative Distribution Function) analysis

### 5. Containerization Ready
- Docker support
- Docker Compose orchestration
- Isolated environments

---

## Target Audience

### Researchers
- Test RAN optimization algorithms
- Validate use cases
- Analyze network performance

### Developers
- Develop and test xApps
- Integrate custom algorithms
- Experiment with RAN control

### Operators
- Understand O-RAN behavior
- Test network configurations
- Train on O-RAN systems

### Students
- Learn O-RAN architecture
- Understand 5G networks
- Practice with real tools

---

## Project Goals

1. **Accessibility**: Make O-RAN testing accessible to everyone
2. **Completeness**: Provide full system-level testing environment
3. **Usability**: Intuitive GUI for non-experts
4. **Extensibility**: Easy to add new xApps and scenarios
5. **Openness**: Fully open-source, no proprietary dependencies

---

## Related Projects

- **FlexRIC**: https://gitlab.eurecom.fr/mosaic5g/flexric
- **ns-O-RAN**: https://openrangym.com/ran-frameworks/ns-o-ran
- **5G-LENA**: https://5g-lena.cttc.es/
- **Sionna RT**: https://nvlabs.github.io/sionna/rt/

---

## License

GNU General Public License v2 - See LICENSE.txt for details.

---

## Contributors

- Orange Innovation Egypt (OIE)
- Orange Innovation Poland (OIP)
- Original component developers (see README.md)

---

**Next**: See installation guide for step-by-step setup instructions.

