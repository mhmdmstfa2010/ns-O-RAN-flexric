#!/bin/bash
# Script to build ns-3 simulator (mmwave-LENA-oran)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NS3_DIR="$PROJECT_DIR/mmwave-LENA-oran"

echo "=========================================="
echo "Building ns-3 simulator (mmwave-LENA-oran)"
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

# Configure ns-3
echo "Configuring ns-3..."
./ns3 configure

# Build ns-3
echo "Building ns-3 (this may take a while)..."
./ns3 build

echo "=========================================="
echo "ns-3 build completed!"
echo "=========================================="

