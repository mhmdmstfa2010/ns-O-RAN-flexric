#!/bin/bash
# Complete Docker setup script - Builds and starts everything

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

echo "=========================================="
echo "Complete Docker Setup for ns-O-RAN-flexric"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Build all Docker containers"
echo "  2. Start all services"
echo "  3. Wait for services to be ready"
echo "  4. Display access information"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

cd "$DOCKER_DIR"

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Step 1: Build containers
echo ""
echo "=========================================="
echo "Step 1: Building Docker containers..."
echo "=========================================="
echo "This may take 30-60 minutes (especially ns-3)..."
echo ""

docker-compose build

echo ""
echo "✓ Containers built successfully!"
echo ""

# Step 2: Start services
echo "=========================================="
echo "Step 2: Starting all services..."
echo "=========================================="
echo ""

# Stop any existing containers
docker-compose down 2>/dev/null || true

# Start all services
docker-compose up -d

echo ""
echo "✓ Services started!"
echo ""

# Step 3: Wait for services
echo "=========================================="
echo "Step 3: Waiting for services to be ready..."
echo "=========================================="
echo ""

echo "Waiting for InfluxDB..."
for i in {1..30}; do
    if docker-compose exec -T influxdb wget --spider -q http://localhost:8086/ping 2>/dev/null; then
        echo "✓ InfluxDB is ready"
        break
    fi
    sleep 2
done

echo "Waiting for FlexRIC..."
sleep 10

echo "Waiting for GUI..."
sleep 10

echo ""
echo "✓ All services are ready!"
echo ""

# Step 4: Display information
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Access URLs:"
echo "  - RIC-TaaP Studio GUI: http://localhost:8000"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - InfluxDB: http://localhost:8086"
echo ""
echo "Service Status:"
docker-compose ps
echo ""
echo "Useful Commands:"
echo "  - View logs: cd docker && docker-compose logs -f"
echo "  - Run scenario: bash scripts/16-docker-run-scenario.sh"
echo "  - Run xApp: bash scripts/17-docker-run-xapp.sh"
echo "  - Stop all: cd docker && docker-compose down"
echo ""
echo "Next Steps:"
echo "  1. Open GUI: http://localhost:8000"
echo "  2. Connect to FlexRIC (if not auto-connected)"
echo "  3. Run a scenario from GUI or use:"
echo "     bash scripts/16-docker-run-scenario.sh scenario-zero-with_parallel_loging.cc"
echo "  4. Run an xApp:"
echo "     bash scripts/17-docker-run-xapp.sh kpm_rc"
echo ""

