#!/bin/bash
# Script to stop all local services (non-Docker)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Stopping All Local Services"
echo "=========================================="
echo ""

# 1. Stop FlexRIC (nearRT-RIC)
echo "1. Stopping FlexRIC (nearRT-RIC)..."
PIDS=$(pgrep -f "nearRT-RIC" || true)
if [ -n "$PIDS" ]; then
    echo "   Found FlexRIC process(es): $PIDS"
    kill -9 $PIDS 2>/dev/null || true
    sleep 2
    echo "   ✓ FlexRIC stopped"
else
    echo "   ✓ No FlexRIC process found"
fi

# 2. Stop processes using port 36421
echo ""
echo "2. Checking port 36421..."
PORT_PIDS=$(sudo lsof -ti :36421 2>/dev/null || true)
if [ -n "$PORT_PIDS" ]; then
    echo "   Found process(es) using port 36421: $PORT_PIDS"
    read -p "   Kill them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo kill -9 $PORT_PIDS 2>/dev/null || true
        echo "   ✓ Port 36421 freed"
    fi
else
    echo "   ✓ Port 36421 is free"
fi

# 3. Stop GUI Trigger (gui_trigger.py)
echo ""
echo "3. Stopping GUI Trigger (gui_trigger.py)..."
GUI_TRIGGER_PIDS=$(pgrep -f "gui_trigger.py" || true)
if [ -n "$GUI_TRIGGER_PIDS" ]; then
    echo "   Found GUI Trigger process(es): $GUI_TRIGGER_PIDS"
    kill -9 $GUI_TRIGGER_PIDS 2>/dev/null || true
    sleep 1
    echo "   ✓ GUI Trigger stopped"
else
    echo "   ✓ No GUI Trigger process found"
fi

# 4. Stop GUI Docker containers (if running locally)
echo ""
echo "4. Stopping GUI Docker containers..."
if [ -d "$PROJECT_ROOT/mmwave-LENA-oran/GUI" ]; then
    cd "$PROJECT_ROOT/mmwave-LENA-oran/GUI"
    if docker-compose ps 2>/dev/null | grep -q "Up"; then
        echo "   Stopping GUI containers..."
        docker-compose down 2>/dev/null || true
        echo "   ✓ GUI containers stopped"
    else
        echo "   ✓ No GUI containers running"
    fi
else
    echo "   ✓ GUI directory not found"
fi

# 5. Stop any ns-3 processes
echo ""
echo "5. Stopping ns-3 processes..."
NS3_PIDS=$(pgrep -f "ns3\|ns-3\|mmwave-LENA" || true)
if [ -n "$NS3_PIDS" ]; then
    echo "   Found ns-3 process(es): $NS3_PIDS"
    kill -9 $NS3_PIDS 2>/dev/null || true
    sleep 1
    echo "   ✓ ns-3 processes stopped"
else
    echo "   ✓ No ns-3 processes found"
fi

# 6. Stop xApp processes
echo ""
echo "6. Stopping xApp processes..."
XAPP_PIDS=$(pgrep -f "xapp_" || true)
if [ -n "$XAPP_PIDS" ]; then
    echo "   Found xApp process(es): $XAPP_PIDS"
    kill -9 $XAPP_PIDS 2>/dev/null || true
    sleep 1
    echo "   ✓ xApp processes stopped"
else
    echo "   ✓ No xApp processes found"
fi

# 7. Check for other Docker containers (from docker-compose in docker/)
echo ""
echo "7. Checking for Docker containers from docker-compose..."
if [ -d "$PROJECT_ROOT/docker" ]; then
    cd "$PROJECT_ROOT/docker"
    if docker-compose ps 2>/dev/null | grep -q "Up"; then
        echo "   Found running Docker containers:"
        docker-compose ps
        read -p "   Stop them? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down 2>/dev/null || true
            echo "   ✓ Docker containers stopped"
        else
            echo "   ⚠ Docker containers still running"
        fi
    else
        echo "   ✓ No Docker containers running"
    fi
fi

# 8. Final check for ports
echo ""
echo "8. Checking for occupied ports..."
PORTS=(8000 3000 8086 36421)
for PORT in "${PORTS[@]}"; do
    PORT_PIDS=$(sudo lsof -ti :$PORT 2>/dev/null || true)
    if [ -n "$PORT_PIDS" ]; then
        echo "   ⚠ Port $PORT is still in use by: $PORT_PIDS"
    else
        echo "   ✓ Port $PORT is free"
    fi
done

echo ""
echo "=========================================="
echo "Stop Operation Completed!"
echo "=========================================="
echo ""
echo "All local services have been stopped."
echo "You can now start Docker services with:"
echo "  bash scripts/14-docker-start.sh"
echo "  or"
echo "  bash scripts/18-docker-complete-setup.sh"
echo ""

