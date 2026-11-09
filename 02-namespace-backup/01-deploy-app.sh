#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
kubectl apply -f namespace-app.yaml
kubectl -n demo-app rollout status deploy/web --timeout=180s
kubectl -n demo-app get all,pvc,cm
echo "--- data file:"
kubectl -n demo-app exec deploy/web -- cat /usr/share/nginx/html/index.html
