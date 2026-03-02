#!/usr/bin/env bash
set -euo pipefail

PROXY_ADDR=localhost:3080
IDENTITIES_DIR=teleport/identities

ENGINEER_IDENTITY="${IDENTITIES_DIR}/engineer"
READONLY_IDENTITY="${IDENTITIES_DIR}/readonly"

echo "=== Test 1: engineer can SSH to lab node (expected: success) ==="
ssh_result=0
tsh ssh --proxy="$PROXY_ADDR" --identity="$ENGINEER_IDENTITY" root@teleport-lab -- echo "ssh-ok" || ssh_result=$?
if [[ "$ssh_result" -ne 0 ]]; then
  echo "Engineer SSH test FAILED with code $ssh_result"
  exit 1
fi
echo "Engineer SSH test passed."

echo "=== Test 2: engineer can reach demo app via Teleport (expected: success) ==="
app_result=0
tsh app login --proxy="$PROXY_ADDR" --identity="$ENGINEER_IDENTITY" demo-app >/dev/null 2>&1
APP_URL=$(tsh app config demo-app --proxy="$PROXY_ADDR" --identity="$ENGINEER_IDENTITY" 2>/dev/null | awk '/^URI/ {print $$2}')
curl -fsSL "${APP_URL}/" >/dev/null 2>&1 || app_result=$?
if [[ "$app_result" -ne 0 ]]; then
  echo "Engineer app access test FAILED with code $app_result"
  exit 1
fi
echo "Engineer app access test passed."

echo "=== Test 3: readonly user cannot SSH to lab node (expected: denied) ==="
deny_result=0
set +e
tsh ssh --proxy="$PROXY_ADDR" --identity="$READONLY_IDENTITY" root@teleport-lab -- echo "should-not-see-this"
deny_result=$?
set -e

if [[ "$deny_result" -eq 0 ]]; then
  echo "Readonly SSH test UNEXPECTEDLY succeeded (should be denied)."
  exit 1
fi

echo "Readonly SSH test correctly denied (exit code $deny_result)."
echo "All tests passed."

