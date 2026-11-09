#!/usr/bin/env bash
# Usage: bash 05-restore.sh [backup-name]
#   no argument -> restore from the latest backup of the schedule
set -euo pipefail
source "$(dirname "$0")/../config.env"
if [ $# -ge 1 ]; then
  velero restore create --from-backup "$1" --wait
else
  velero restore create --from-schedule "$SCHEDULE_NAME" --wait
fi
velero restore get
