#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config.env"
kubectl -n "$NAMESPACE" get all,pvc,cm
kubectl -n "$NAMESPACE" rollout status deploy/web --timeout=180s
echo "--- restored data (original timestamp = data was restored):"
kubectl -n "$NAMESPACE" exec deploy/web -- cat /usr/share/nginx/html/index.html
