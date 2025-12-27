#!/bin/bash
# Master script to setup and run the entire project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "ns-O-RAN-flexric Complete Setup"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Install dependencies"
echo "2. Install FlexRIC"
echo "3. Build e2sim-kpmv3"
echo "4. Build ns-3 simulator"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Step 1: Install dependencies
echo ""
echo ">>> Step 1: Installing dependencies..."
bash "$SCRIPT_DIR/01-install-dependencies.sh"

# Step 2: Install FlexRIC
echo ""
echo ">>> Step 2: Installing FlexRIC..."
bash "$SCRIPT_DIR/02-install-flexric.sh"

# Step 3: Build e2sim
echo ""
echo ">>> Step 3: Building e2sim-kpmv3..."
bash "$SCRIPT_DIR/03-build-e2sim.sh"

# Step 4: Build ns-3
echo ""
echo ">>> Step 4: Building ns-3 simulator..."
bash "$SCRIPT_DIR/04-build-ns3.sh"

echo ""
echo "=========================================="
echo "Setup completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Start FlexRIC: bash $SCRIPT_DIR/05-start-flexric.sh"
echo "2. Start GUI: bash $SCRIPT_DIR/06-start-gui.sh"
echo "3. Start GUI trigger: bash $SCRIPT_DIR/07-start-gui-trigger.sh"
echo ""

