#!/bin/bash
# Script to install all dependencies for ns-O-RAN-flexric

set -e

echo "=========================================="
echo "Installing Dependencies for ns-O-RAN-flexric"
echo "=========================================="

# Update package list
sudo apt-get update

# E2sim requirements
echo "Installing E2sim requirements..."
sudo apt-get install -y \
  build-essential \
  git \
  cmake \
  libsctp-dev \
  autoconf \
  automake \
  libtool \
  bison \
  flex \
  libboost-all-dev \
  asn1c

# ns-3 requirements
echo "Installing ns-3 requirements..."
sudo apt-get install -y \
  g++ \
  python3 \
  python3-pip \
  libc6-dev

# Optional dependencies for advanced features
echo "Installing optional dependencies..."
sudo apt-get install -y \
  sqlite3 \
  libsqlite3-dev \
  libeigen3-dev

# Docker Compose (if not installed)
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
fi

# Install Python dependencies for GUI
echo "Installing Python dependencies..."
# Use apt package for Ubuntu 24.04+ (externally-managed-environment)
sudo apt-get install -y python3-influxdb || {
    echo "python3-influxdb not found in apt, trying pip with --break-system-packages..."
    pip3 install --break-system-packages influxdb || echo "Warning: Could not install influxdb"
}

echo "=========================================="
echo "Dependencies installation completed!"
echo "=========================================="

