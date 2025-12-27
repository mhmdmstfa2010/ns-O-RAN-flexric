#!/bin/bash
# Script to start GUI trigger (pushes ns3 KPIs to database)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NS3_DIR="$PROJECT_DIR/mmwave-LENA-oran"

echo "=========================================="
echo "Starting GUI Trigger (ns3 KPIs pusher)"
echo "=========================================="

# Check if mmwave-LENA-oran directory exists
if [ ! -d "$NS3_DIR" ]; then
    echo "✗ Error: mmwave-LENA-oran directory not found at $NS3_DIR"
    echo ""
    echo "This is a git submodule. Please run:"
    echo "  cd $PROJECT_DIR"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
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

