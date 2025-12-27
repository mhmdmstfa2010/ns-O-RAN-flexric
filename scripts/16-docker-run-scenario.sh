#!/bin/bash
# Script to run ns-3 scenario inside Docker container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

# Default scenario
SCENARIO="${1:-scenario-zero-with_parallel_loging.cc}"
E2TERM_IP="${2:-e2sim}"

echo "=========================================="
echo "Running ns-3 Scenario in Docker"
echo "=========================================="
echo "Scenario: $SCENARIO"
echo "E2 Termination IP: $E2TERM_IP"
echo ""

cd "$DOCKER_DIR"

# Check if containers are running
if ! docker-compose ps | grep -q "ns-oran-ns3.*Up"; then
    echo "Error: ns3-simulator container is not running."
    echo "Please start containers first: bash scripts/14-docker-start.sh"
    exit 1
fi

# Build scenario command
SCENARIO_PATH="scratch/$SCENARIO"
CMD="./ns3 run \"$SCENARIO_PATH --e2TermIp=$E2TERM_IP --indicationPeriodicity=0.1 --simTime=1000 --KPM_E2functionID=2 --RC_E2functionID=3 --N_MmWaveEnbNodes=4 --N_Ues=3 --CenterFrequency=3.5e9 --Bandwidth=20e6\""

echo "Executing scenario in Docker container..."
echo "Command: $CMD"
echo ""

# Execute scenario in container
docker-compose exec ns3-simulator bash -c "cd /opt/ns3 && $CMD"

echo ""
echo "=========================================="
echo "Scenario execution completed!"
echo "=========================================="

