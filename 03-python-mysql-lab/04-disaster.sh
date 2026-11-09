#!/usr/bin/env bash
# Delete both namespaces (simulated disaster). FORCE=1 skips the question.
set -euo pipefail
source "$(dirname "$0")/../config.env"
if [ "${FORCE:-0}" != "1" ]; then
  read -rp "Delete namespaces ${APP_NS} and ${DB_NS}? (yes/no) " a
  [ "$a" = "yes" ] || exit 0
fi
pkill -f "port-forward" 2>/dev/null || true
kubectl delete ns "$APP_NS" "$DB_NS" --wait=true
kubectl get ns | grep -E "${APP_NS}|${DB_NS}" || echo "Namespaces gone."
