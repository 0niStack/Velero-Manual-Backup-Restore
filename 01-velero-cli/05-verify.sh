#!/usr/bin/env bash
# Step 5: verify the install and that RustFS is reachable
set -euo pipefail
velero version
velero backup-location get          # PHASE must be "Available"
kubectl -n velero get pods
