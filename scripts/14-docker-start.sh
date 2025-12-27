#!/bin/bash
# Script to start all Docker containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "=========================================="
echo "Starting Docker Containers for ns-O-RAN-flexric"
echo "=========================================="

cd "$DOCKER_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if containers are already running
if docker-compose ps | grep -q "Up"; then
    echo "⚠ Some containers are already running."
    read -p "Do you want to restart them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping existing containers..."
        docker-compose down
    else
        echo "Keeping existing containers running."
        exit 0
    fi
fi

echo ""
echo "Starting all services..."
echo ""

# Start all services in detached mode
docker-compose up -d

echo ""
echo "Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "=========================================="
echo "✓ All services started!"
echo "=========================================="
echo ""
echo "Access URLs:"
echo "  - RIC-TaaP Studio GUI: http://localhost:8000"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - InfluxDB: http://localhost:8086"
echo ""
echo "Useful commands:"
echo "  - View logs: cd docker && docker-compose logs -f"
echo "  - Stop services: cd docker && docker-compose down"
echo "  - Restart: cd docker && docker-compose restart"
echo ""

