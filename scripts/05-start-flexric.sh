#!/bin/bash
# Script to start FlexRIC (nearRT-RIC)

set -e

FLEXRIC_DIR="/home/mhmd/Documents/o-ran/flexric"
RIC_BINARY="$FLEXRIC_DIR/build/examples/ric/nearRT-RIC"

echo "=========================================="
echo "Starting FlexRIC (nearRT-RIC)"
echo "=========================================="

# Check if FlexRIC is built
if [ ! -f "$RIC_BINARY" ]; then
    echo "Error: FlexRIC binary not found at $RIC_BINARY"
    echo "Please run 02-install-flexric.sh first"
    exit 1
fi

cd "$FLEXRIC_DIR/build/examples/ric"

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

echo "Starting nearRT-RIC on port 36421..."
echo "Press Ctrl+C to stop"
./nearRT-RIC

