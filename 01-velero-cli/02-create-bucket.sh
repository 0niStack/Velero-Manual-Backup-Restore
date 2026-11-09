#!/usr/bin/env bash
# Step 2: create the Velero bucket in RustFS (uses aws cli, or docker if aws is missing)
set -euo pipefail
cd "$(dirname "$0")"
source ../config.env
export AWS_ACCESS_KEY_ID="$RUSTFS_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$RUSTFS_SECRET_KEY" AWS_DEFAULT_REGION="$REGION"

if command -v aws >/dev/null; then
  AWS="aws"
else
  AWS="docker run --rm --network host -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION amazon/aws-cli"
fi

$AWS --endpoint-url "$S3_URL" s3 mb "s3://${BUCKET}" || echo "bucket may already exist"
$AWS --endpoint-url "$S3_URL" s3 ls
