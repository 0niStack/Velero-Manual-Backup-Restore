#!/usr/bin/env bash
# Step 4: install Velero server components into the cluster (backend = RustFS)
set -euo pipefail
cd "$(dirname "$0")"
source ../config.env
[ -f credentials-velero ] || { echo "Run 01-start-rustfs.sh first (creates credentials-velero)"; exit 1; }

velero install \
  --provider aws \
  --plugins "velero/velero-plugin-for-aws:${AWS_PLUGIN_VERSION}" \
  --bucket "$BUCKET" \
  --secret-file ./credentials-velero \
  --backup-location-config "region=${REGION},s3ForcePathStyle=true,s3Url=${S3_URL}" \
  --use-volume-snapshots=false \
  --use-node-agent \
  --wait

echo
kubectl -n velero get pods
