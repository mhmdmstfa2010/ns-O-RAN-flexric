#!/bin/bash
# Script to kill existing FlexRIC processes

echo "=========================================="
echo "Killing FlexRIC processes"
echo "=========================================="

# Find and kill nearRT-RIC processes
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

echo "=========================================="
echo "Done!"
echo "=========================================="

