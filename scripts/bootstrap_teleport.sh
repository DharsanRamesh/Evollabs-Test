#!/usr/bin/env bash
set -euo pipefail

# This script runs inside the host, but uses docker exec to talk to the Teleport auth service.

TELEPORT_CONTAINER=teleport
IDENTITIES_DIR=/var/lib/teleport-identities

echo "Creating Teleport roles and users..."

docker exec -i "$TELEPORT_CONTAINER" tctl create -f - < teleport/resources/roles.yaml
docker exec -i "$TELEPORT_CONTAINER" tctl create -f - < teleport/resources/users.yaml

echo "Generating non-interactive identity files..."
docker exec "$TELEPORT_CONTAINER" tctl auth sign --user=engineer --out="${IDENTITIES_DIR}/engineer" --overwrite
docker exec "$TELEPORT_CONTAINER" tctl auth sign --user=readonly --out="${IDENTITIES_DIR}/readonly" --overwrite

echo "Bootstrap completed. Identities stored under teleport/identities on the host."

