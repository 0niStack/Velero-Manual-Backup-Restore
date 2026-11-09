#!/usr/bin/env bash
# Manual backup right now (do not wait for the cron)
set -euo pipefail
source "$(dirname "$0")/../config.env"
NAME="${NAMESPACE}-manual-$(date +%Y%m%d-%H%M%S)"
velero backup create "$NAME" \
  --include-namespaces "$NAMESPACE" \
  --default-volumes-to-fs-backup \
  --wait
velero backup describe "$NAME" --details
velero backup get
