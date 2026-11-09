#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config.env"
kubectl -n "$DB_NS" get pods,pvc
kubectl -n "$APP_NS" get pods
kubectl get networkpolicy -A | grep -E "${APP_NS}|${DB_NS}"
kubectl -n "$APP_NS" port-forward "svc/${APP_SVC}" "${LOCAL_PORT}:80" >/dev/null 2>&1 &
PF=$!; trap 'kill $PF 2>/dev/null || true' EXIT
sleep 4
echo "--- GET /items"
curl -sS "localhost:${LOCAL_PORT}/items"; echo
