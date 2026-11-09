#!/usr/bin/env bash
# Step 1: start RustFS (run on the storage host) and write credentials-velero
set -euo pipefail
cd "$(dirname "$0")"
source ../config.env
export RUSTFS_ACCESS_KEY RUSTFS_SECRET_KEY

docker compose -f rustfs/docker-compose.yml up -d
docker compose -f rustfs/docker-compose.yml ps

cat > credentials-velero <<CRED
[default]
aws_access_key_id=${RUSTFS_ACCESS_KEY}
aws_secret_access_key=${RUSTFS_SECRET_KEY}
CRED
chmod 600 credentials-velero

echo "RustFS API:     ${S3_URL}"
echo "RustFS console: http://<host>:9001  (login with the access/secret key)"
