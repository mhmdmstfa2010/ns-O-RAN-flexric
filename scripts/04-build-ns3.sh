#!/bin/bash
# Script to build ns-3 simulator (mmwave-LENA-oran)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NS3_DIR="$PROJECT_DIR/mmwave-LENA-oran"

echo "=========================================="
echo "Building ns-3 simulator (mmwave-LENA-oran)"
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

# Configure ns-3
echo "Configuring ns-3..."
./ns3 configure

# Build ns-3
echo "Building ns-3 (this may take a while)..."
./ns3 build

echo "=========================================="
echo "ns-3 build completed!"
echo "=========================================="

