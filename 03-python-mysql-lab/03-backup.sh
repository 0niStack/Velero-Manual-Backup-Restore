#!/usr/bin/env bash
# SQL dump + Velero backup of myapp and mydb
# Usage: make mysql-backup [BACKUP=name]
set -euo pipefail
cd "$(dirname "$0")"
source ../config.env
bash ./01-dump.sh

NAME="${BACKUP:-pymysql-$(date +%Y%m%d-%H%M%S)}"
velero backup create "$NAME" --include-namespaces "${APP_NS},${DB_NS}" --wait
velero backup describe "$NAME" | sed -n '1,12p'
echo "$NAME" > backups/last-velero-backup.txt
echo "Saved backup name: $NAME"
