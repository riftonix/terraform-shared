#!/bin/sh
set -eu

: "${LOCK_FILE:?LOCK_FILE is required}"
: "${ROUTER_IP:?ROUTER_IP is required}"
: "${NEW_PASSWORD:?NEW_PASSWORD is required}"

if [ -f "$LOCK_FILE" ]; then
  echo "Lock file exists, router already initialized: $LOCK_FILE"
  exit 0
fi

echo "Waiting for router REST API and setting password..."

MAX_ATTEMPTS=30
i=1
while [ "$i" -le "$MAX_ATTEMPTS" ]; do
  if curl -k -sS -m 10 --connect-timeout 5 \
    -u "admin:" \
    -H "Content-Type: application/json" \
    -X POST "http://$ROUTER_IP/rest/password" \
    -d "{\"old-password\":\"\",\"new-password\":\"$NEW_PASSWORD\",\"confirm-new-password\":\"$NEW_PASSWORD\"}"; then
    touch "$LOCK_FILE"
    echo "Password changed. Lock file created: $LOCK_FILE"
    exit 0
  fi

  echo "Attempt $i/$MAX_ATTEMPTS failed, sleep 5s..."
  sleep 5
  i=$((i + 1))
done

echo "Failed to set router password after retries"
exit 1
