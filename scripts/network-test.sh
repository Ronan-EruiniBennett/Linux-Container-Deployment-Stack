#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./scripts/config.sh
source "$SCRIPT_DIR/config.sh"

### HOST DOCKER NETWORK STATE ###
# Confirms Docker's host-side bridge exists and has an IP address.
# Also checks that the VM host has a route to the Docker bridge subnet via docker0.

echo "== Host Docker network state =="

# Check if the docker0 interface exists.
echo "[1] Checking data link layer state of docker0 interface:"
if ip link show docker0 >/dev/null 2>&1; then
    echo "PASS: docker0 interface exists"
else
    echo "FAIL: docker0 interface does not exist"
    echo "Meaning: Docker may not be running, bridge networking may be disabled, or Docker may be misconfigured."
    exit 1
fi

# Check if the docker0 interface has an IPv4 address assigned.
echo "[2] Checking IPv4 address of docker0 interface:"
if ip -4 addr show docker0 2>/dev/null | grep -q "inet "; then
    echo "PASS: docker0 interface has an IPv4 address"
    ip -4 addr show docker0
else
    echo "FAIL: docker0 interface does not have an IPv4 address"
    echo "Meaning: docker0 exists at Layer 2, but may not have a usable Layer 3 subnet."
    exit 1
fi

# Check if the VM host has a route to the Docker bridge subnet via docker0.
echo
echo "[3] Checking VM host route to the Docker bridge subnet via docker0:"
if ip route show dev docker0 2>/dev/null | grep -q .; then
    echo "PASS: VM host has a route to the Docker bridge subnet via docker0"
    ip route show dev docker0
else
    echo "FAIL: VM host does not have a route to the Docker bridge subnet via docker0"
    echo "Meaning: docker0 may exist, but the VM host may not know how to route traffic to containers on the Docker bridge subnet."
    exit 1
fi


### CONTAINER NETWORK STATE ###

echo "== Container network state =="

# Check if the container exists and is running.
echo "[1] Checking container exists:"
if sudo docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
    echo "PASS: Container '$NAME' is running"
else
    echo "FAIL: Container '$NAME' is not running"
    echo "Meaning: The container may not have started successfully, or may have exited due to an error."
    exit 1
fi

# Check if the container has any port mappings.
echo "[2] Checking container port mapping:"
if sudo docker port "$NAME" 2>/dev/null | grep -q .; then
    echo "PASS: Container '$NAME' has port mappings"
    sudo docker port "$NAME"
else
    echo "FAIL: Container '$NAME' does not have any port mappings"
    echo "Meaning: The container may be running, but may not be accessible from the host or Nginx due to missing port mappings."
    exit 1
fi

# Check if the container is connected to a network and has an IP address.
echo "[3] Checking container networks and IP addresses:"
if sudo docker inspect "$NAME" --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null | grep -q .; then
    echo "PASS: Container '$NAME' is connected to a network and has an IP address"
    sudo docker inspect "$NAME" --format '{{range $network, $config := .NetworkSettings.Networks}}Network={{$network}}{{println}}Gateway={{$config.Gateway}}{{println}}IP={{$config.IPAddress}}{{println}}MAC={{$config.MacAddress}}{{println}}{{end}}'
else
    echo "FAIL: Container '$NAME' is not connected to any network or does not have an IP address"
    echo "Meaning: The container may not be attached to a Docker network, or Docker network assignment failed."
    exit 1
fi

### EGRESS TESTS ###
# Confirms the VM and container can reach the public internet by IP.
# Then checks DNS resolution separately so DNS failures are not confused with general connectivity failures.

### INGRESS / SERVICE PATH TESTS ###
# Confirms the VM has expected listening ports.
# Then tests the backend directly and through Nginx to distinguish app/container faults from reverse-proxy faults.

### INGRESS TESTS ###
# IP link to check container brigde exists at data link layer
# IP addr to check container bridge has an ip address
# IP route to check container bridge has a default route
# ss -tulpen to check listening ports



### EGRESS TESTS ###
# Vm connectivity test ping
# Vm dns test ping google.com
# Container connectivity test ping
# Container dns test ping google.com
# Container exec ip route to check default route exists
# Container exec ip addr to check container has an ip address

