#!/usr/bin/env bash
set -euo pipefail

RETRIES=30
SLEEP=4

echo "Checking Teleport proxy /webapi/ping endpoint..."

for i in $(seq 1 "$RETRIES"); do
  if curl -sk https://localhost:3080/webapi/ping >/dev/null 2>&1; then
    echo "Teleport proxy is responding."
    exit 0
  fi
  echo "Teleport not ready yet (attempt $i/$RETRIES), retrying in ${SLEEP}s..."
  sleep "$SLEEP"
done

echo "Teleport did not become ready in time."
exit 1

