#!/usr/bin/env bash
# Fix "Pending / Insufficient cpu" on an already installed Velero
set -euo pipefail
source "$(dirname "$0")/../config.env"
P='[{"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/cpu","value":"'"$CPU_REQ"'"},{"op":"replace","path":"/spec/template/spec/containers/0/resources/requests/memory","value":"'"$MEM_REQ"'"}]'
kubectl -n velero patch deploy velero --type json -p "$P"
kubectl -n velero patch ds node-agent --type json -p "$P"
kubectl -n velero rollout status deploy/velero --timeout=180s
kubectl -n velero get pods
