#!/usr/bin/env bash
# Step 3: install the velero CLI on this machine
set -euo pipefail
source "$(dirname "$0")/../config.env"

ARCH="$(uname -m)"; case "$ARCH" in x86_64) ARCH=amd64;; aarch64|arm64) ARCH=arm64;; esac
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
TARBALL="velero-${VELERO_VERSION}-${OS}-${ARCH}.tar.gz"

cd /tmp
curl -fL -O "https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/${TARBALL}"
tar -xzf "$TARBALL"
sudo install -m 0755 "velero-${VELERO_VERSION}-${OS}-${ARCH}/velero" /usr/local/bin/velero
rm -rf "$TARBALL" "velero-${VELERO_VERSION}-${OS}-${ARCH}"

velero version --client-only
echo "Optional shell completion:  source <(velero completion bash)"
