#!/bin/bash
# Script to start the entire system (FlexRIC + GUI + GUI Trigger)

set -e

PROJECT_DIR="/home/mhmd/Documents/o-ran/ns-O-RAN-flexric"
SCRIPT_DIR="$PROJECT_DIR/scripts"

echo "=========================================="
echo "Starting ns-O-RAN-flexric System"
echo "=========================================="
echo ""

# Check if all components are ready
echo "Checking system components..."

# Check FlexRIC
if [ ! -f "/home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC" ]; then
    echo "✗ Error: FlexRIC not found. Please run 02-install-flexric.sh first"
    exit 1
fi
echo "✓ FlexRIC ready"

# Check e2sim
if [ ! -f "$PROJECT_DIR/e2sim-kpmv3/e2sim/build/e2sim-dev_1.0.0_amd64.deb" ]; then
    echo "✗ Error: e2sim not built. Please run 03-build-e2sim.sh first"
    exit 1
fi
echo "✓ e2sim ready"

# Check ns-3
cd "$PROJECT_DIR/mmwave-LENA-oran"
if ! ./ns3 --help >/dev/null 2>&1; then
    echo "✗ Error: ns-3 not built. Please run 04-build-ns3.sh first"
    exit 1
fi
echo "✓ ns-3 ready"
echo ""

# Kill any existing processes
echo "Cleaning up existing processes..."
bash "$SCRIPT_DIR/11-kill-flexric.sh" 2>/dev/null || true
echo ""

# Start FlexRIC in background
echo "=========================================="
echo "Step 1: Starting FlexRIC"
echo "=========================================="
cd "$PROJECT_DIR"
bash "$SCRIPT_DIR/05-start-flexric.sh" &
FLEXRIC_PID=$!
echo "FlexRIC started with PID: $FLEXRIC_PID"
sleep 5
echo ""

# Start GUI
echo "=========================================="
echo "Step 2: Starting RIC-TaaP Studio GUI"
echo "=========================================="
bash "$SCRIPT_DIR/06-start-gui.sh"
sleep 10
echo ""

# Start GUI Trigger
echo "=========================================="
echo "Step 3: Starting GUI Trigger (KPI Pusher)"
echo "=========================================="
cd "$PROJECT_DIR/mmwave-LENA-oran"
if [ -f "gui_trigger.py" ]; then
    python3 gui_trigger.py &
    TRIGGER_PID=$!
    echo "GUI Trigger started with PID: $TRIGGER_PID"
else
    echo "⚠ Warning: gui_trigger.py not found"
fi
echo ""

# Get host IP
HOST_IP=$(hostname -I | awk '{print $1}')

echo "=========================================="
echo "System Started Successfully!"
echo "=========================================="
echo ""
echo "Access points:"
echo "  📊 RIC-TaaP Studio: http://$HOST_IP:8000"
echo "  📈 Grafana:         http://$HOST_IP:3000"
echo ""
echo "Running processes:"
echo "  - FlexRIC (nearRT-RIC): PID $FLEXRIC_PID"
if [ -n "$TRIGGER_PID" ]; then
    echo "  - GUI Trigger:          PID $TRIGGER_PID"
fi
echo ""
echo "To stop the system:"
echo "  bash $SCRIPT_DIR/11-kill-flexric.sh"
echo "  cd $PROJECT_DIR/mmwave-LENA-oran/GUI && docker-compose down"
echo ""

