#!/usr/bin/env bash
# Delete the whole namespace to simulate an accident
set -euo pipefail
source "$(dirname "$0")/../config.env"
read -rp "Delete namespace '$NAMESPACE'? (yes/no) " a
[ "$a" = "yes" ] || exit 0
kubectl delete namespace "$NAMESPACE" --wait=true
kubectl get ns | grep "$NAMESPACE" || echo "Namespace gone."
