#!/bin/bash
# Script to start RIC-TaaP Studio GUI

set -e

PROJECT_DIR="/home/mhmd/Documents/o-ran/ns-O-RAN-flexric"
GUI_DIR="$PROJECT_DIR/mmwave-LENA-oran/GUI"
NS3_DIR="$PROJECT_DIR/mmwave-LENA-oran"

echo "=========================================="
echo "Starting RIC-TaaP Studio GUI"
echo "=========================================="

# Get the host IP address
HOST_IP=$(hostname -I | awk '{print $1}')
echo "Detected host IP: $HOST_IP"

# Update docker-compose.yml with host IP
cd "$GUI_DIR"
if [ -f "docker-compose.yml" ]; then
    # Backup original
    cp docker-compose.yml docker-compose.yml.bak
    
    # Update NS3_HOST in docker-compose.yml
    sed -i "s/NS3_HOST=.*/NS3_HOST=$HOST_IP/" docker-compose.yml
    echo "Updated NS3_HOST to $HOST_IP in docker-compose.yml"
fi

# Start GUI with Docker Compose
echo "Starting GUI services (this may take a few minutes)..."
docker-compose up --build -d

echo "=========================================="
echo "GUI is starting..."
echo "Access RIC-TaaP Studio at: http://$HOST_IP:8000"
echo "Access Grafana at: http://$HOST_IP:3000"
echo "=========================================="
echo ""
echo "To view logs: docker-compose -f $GUI_DIR/docker-compose.yml logs -f"
echo "To stop GUI: docker-compose -f $GUI_DIR/docker-compose.yml down"

