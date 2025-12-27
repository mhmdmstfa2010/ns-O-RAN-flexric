#!/bin/bash
# Script to start GUI trigger (pushes ns3 KPIs to database)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NS3_DIR="$PROJECT_DIR/mmwave-LENA-oran"

echo "=========================================="
echo "Starting GUI Trigger (ns3 KPIs pusher)"
echo "=========================================="

# Check if mmwave-LENA-oran directory exists or is empty (submodule not initialized)
if [ ! -d "$NS3_DIR" ] || [ -z "$(ls -A $NS3_DIR 2>/dev/null)" ]; then
    echo "⚠ mmwave-LENA-oran submodule not initialized. Initializing..."
    cd "$PROJECT_DIR"
    git submodule update --init --recursive mmwave-LENA-oran
    if [ $? -ne 0 ]; then
        echo "✗ Error: Failed to initialize mmwave-LENA-oran submodule"
        echo ""
        echo "Please run manually:"
        echo "  cd $PROJECT_DIR"
        echo "  git submodule update --init --recursive"
        echo ""
        exit 1
    fi
    echo "✓ mmwave-LENA-oran submodule initialized"
fi

cd "$NS3_DIR"

# Check if gui_trigger.py exists
if [ ! -f "gui_trigger.py" ]; then
    echo "Error: gui_trigger.py not found"
    exit 1
fi

echo "Starting GUI trigger..."
echo "This script will push ns3 KPIs to InfluxDB"
echo "Press Ctrl+C to stop"
python3 gui_trigger.py

