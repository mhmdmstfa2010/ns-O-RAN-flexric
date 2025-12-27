#!/bin/bash
# Script to build e2sim-kpmv3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
E2SIM_DIR="$PROJECT_DIR/e2sim-kpmv3/e2sim"

echo "=========================================="
echo "Building e2sim-kpmv3"
echo "=========================================="

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

