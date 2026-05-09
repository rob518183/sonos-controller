#!/bin/sh
set -e

# Default ports, overridable from Docker run env
export PORT=${PORT:-3000}
export API_PORT=${API_PORT:-5005}

# Start Sonos HTTP API and controller server in the same container
node ./node_modules/node-sonos-http-api/server.js &
API_PID=$!
node ./server.js &
CTRL_PID=$!

cleanup() {
  [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null || true
  [ -n "$CTRL_PID" ] && kill "$CTRL_PID" 2>/dev/null || true
}

trap 'cleanup' INT TERM

while true; do
  if ! kill -0 "$API_PID" 2>/dev/null; then
    wait "$API_PID"
    STATUS=$?
    cleanup
    exit "$STATUS"
  fi
  if ! kill -0 "$CTRL_PID" 2>/dev/null; then
    wait "$CTRL_PID"
    STATUS=$?
    cleanup
    exit "$STATUS"
  fi
  sleep 1
 done