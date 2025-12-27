#!/bin/bash
# Script to start GUI trigger (pushes ns3 KPIs to database)

set -e

PROJECT_DIR="/home/mhmd/Documents/o-ran/ns-O-RAN-flexric"
NS3_DIR="$PROJECT_DIR/mmwave-LENA-oran"

echo "=========================================="
echo "Starting GUI Trigger (ns3 KPIs pusher)"
echo "=========================================="

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

