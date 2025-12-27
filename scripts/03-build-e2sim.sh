#!/bin/bash
# Script to build e2sim-kpmv3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
E2SIM_DIR="$PROJECT_DIR/e2sim-kpmv3/e2sim"

echo "=========================================="
echo "Building e2sim-kpmv3"
echo "=========================================="

# Check if e2sim-kpmv3 directory exists or is empty (submodule not initialized)
if [ ! -d "$PROJECT_DIR/e2sim-kpmv3" ] || [ -z "$(ls -A $PROJECT_DIR/e2sim-kpmv3 2>/dev/null)" ]; then
    echo "⚠ e2sim-kpmv3 submodule not initialized. Initializing..."
    cd "$PROJECT_DIR"
    git submodule update --init --recursive e2sim-kpmv3
    if [ $? -ne 0 ]; then
        echo "✗ Error: Failed to initialize e2sim-kpmv3 submodule"
        echo ""
        echo "Please run manually:"
        echo "  cd $PROJECT_DIR"
        echo "  git submodule update --init --recursive"
        echo ""
        exit 1
    fi
    echo "✓ e2sim-kpmv3 submodule initialized"
fi

# Check if e2sim subdirectory exists
if [ ! -d "$E2SIM_DIR" ]; then
    echo "✗ Error: e2sim directory not found at $E2SIM_DIR"
    echo ""
    echo "Please ensure the git submodule is properly initialized:"
    echo "  cd $PROJECT_DIR"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
fi

cd "$E2SIM_DIR"

# Create build directory
mkdir -p build

# Build e2sim with LOG_LEVEL 2 (INFO)
echo "Building e2sim with LOG_LEVEL=2 (INFO)..."
cd build
sudo ../build_e2sim.sh 2

echo "=========================================="
echo "e2sim build completed!"
echo "=========================================="

