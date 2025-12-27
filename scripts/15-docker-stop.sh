#!/bin/bash
# Script to stop all Docker containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "=========================================="
echo "Stopping Docker Containers for ns-O-RAN-flexric"
echo "=========================================="

cd "$DOCKER_DIR"

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "No containers are running."
    exit 0
fi

echo ""
echo "Stopping all services..."
echo ""

# Stop all services
docker-compose down

echo ""
echo "=========================================="
echo "✓ All services stopped!"
echo "=========================================="
echo ""

