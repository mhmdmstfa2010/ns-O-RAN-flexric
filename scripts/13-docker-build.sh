#!/bin/bash
# Script to build all Docker containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "=========================================="
echo "Building Docker Containers for ns-O-RAN-flexric"
echo "=========================================="

cd "$DOCKER_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Build options
BUILD_OPTIONS=""
if [ "$1" == "--no-cache" ]; then
    BUILD_OPTIONS="--no-cache"
    echo "Building without cache..."
fi

echo ""
echo "Building containers (this may take 30-60 minutes)..."
echo ""

# Build all services
docker-compose build $BUILD_OPTIONS

echo ""
echo "=========================================="
echo "✓ All containers built successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Start all services: cd docker && docker-compose up -d"
echo "  2. View logs: docker-compose logs -f"
echo "  3. Access GUI: http://localhost:8000"
echo "  4. Access Grafana: http://localhost:3000"
echo ""

