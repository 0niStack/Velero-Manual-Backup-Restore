#!/usr/bin/env bash
# Optional: remove Velero from the cluster (RustFS and its data stay)
set -euo pipefail
velero uninstall --force
