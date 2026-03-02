#!/usr/bin/env bash
set -euo pipefail

# This script runs inside the host, but uses docker exec to talk to the Teleport auth service.

TELEPORT_CONTAINER=teleport
RESOURCES_DIR=/etc/teleport/resources
IDENTITIES_DIR=/var/lib/teleport-identities

echo "Creating Teleport roles and users..."

docker exec "$TELEPORT_CONTAINER" tctl create "${RESOURCES_DIR}/roles.yaml"
docker exec "$TELEPORT_CONTAINER" tctl create "${RESOURCES_DIR}/users.yaml"

echo "Generating non-interactive identity files..."
docker exec "$TELEPORT_CONTAINER" tctl auth sign --user=engineer --out="${IDENTITIES_DIR}/engineer"
docker exec "$TELEPORT_CONTAINER" tctl auth sign --user=readonly --out="${IDENTITIES_DIR}/readonly"

echo "Bootstrap completed. Identities stored under teleport/identities on the host."

