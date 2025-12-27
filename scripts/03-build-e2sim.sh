#!/bin/bash
# Script to build e2sim-kpmv3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
E2SIM_DIR="$PROJECT_DIR/e2sim-kpmv3/e2sim"

echo "=========================================="
echo "Building e2sim-kpmv3"
echo "=========================================="

# Check if e2sim-kpmv3 directory exists
if [ ! -d "$PROJECT_DIR/e2sim-kpmv3" ]; then
    echo "✗ Error: e2sim-kpmv3 directory not found at $PROJECT_DIR/e2sim-kpmv3"
    echo ""
    echo "This is a git submodule. Please run:"
    echo "  cd $PROJECT_DIR"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
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

