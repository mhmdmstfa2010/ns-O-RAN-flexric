#!/bin/bash
# Script to run xApp inside Docker container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

# Default xApp
XAPP="${1:-kpm_rc}"
XAPP_NAME="xapp_${XAPP}"

echo "=========================================="
echo "Running xApp in Docker"
echo "=========================================="
echo "xApp: $XAPP_NAME"
echo ""

cd "$DOCKER_DIR"

# Check if FlexRIC container is running
if ! docker-compose ps | grep -q "ns-oran-flexric.*Up"; then
    echo "Error: flexric container is not running."
    echo "Please start containers first: bash scripts/14-docker-start.sh"
    exit 1
fi

# Map xApp names to paths
case $XAPP in
    kpm_rc)
        XAPP_PATH="/opt/flexric/build/examples/xApp/c/kpm_rc/xapp_kpm_rc"
        ;;
    es_with_cell_util)
        XAPP_PATH="/opt/flexric/build/examples/xApp/c/orange/xapp_es_with_cell_util"
        ;;
    rc_handover_ctrl)
        XAPP_PATH="/opt/flexric/build/examples/xApp/c/ctrl/xapp_rc_handover_ctrl"
        ;;
    *)
        echo "Error: Unknown xApp: $XAPP"
        echo "Available xApps: kpm_rc, es_with_cell_util, rc_handover_ctrl"
        exit 1
        ;;
esac

echo "Running xApp: $XAPP_PATH"
echo ""

# Execute xApp in container
docker-compose exec flexric bash -c "cd $(dirname $XAPP_PATH) && $XAPP_PATH"

echo ""
echo "=========================================="
echo "xApp execution completed!"
echo "=========================================="

