#!/usr/bin/env bash
# Velero restore + load the SQL dump + restart the app
# Usage: make mysql-restore [BACKUP=velero-backup-name]
set -euo pipefail
cd "$(dirname "$0")"
source ../config.env

BACKUP="${BACKUP:-$(cat backups/last-velero-backup.txt 2>/dev/null || true)}"
[ -n "$BACKUP" ] || { echo "No backup name. Run: make mysql-restore BACKUP=<name>  (see: make status)"; exit 1; }
[ -f backups/latest.sql ] || { echo "backups/latest.sql missing, run make mysql-dump first"; exit 1; }

velero restore create "pymysql-r-$(date +%Y%m%d-%H%M%S)" --from-backup "$BACKUP" --wait

echo "Waiting for ${MYSQL_POD}..."
for i in $(seq 1 60); do kubectl -n "$DB_NS" get pod "$MYSQL_POD" >/dev/null 2>&1 && break; sleep 3; done
kubectl -n "$DB_NS" wait --for=condition=Ready "pod/${MYSQL_POD}" --timeout=300s

echo "Loading SQL dump..."
for i in $(seq 1 12); do
  if kubectl -n "$DB_NS" exec -i "$MYSQL_POD" -- sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < backups/latest.sql; then
    echo "Dump loaded."; break
  fi
  echo "MySQL not ready yet, retry $i/12..."; sleep 5
done

kubectl -n "$APP_NS" rollout restart deploy/"$APP_SVC"
kubectl -n "$APP_NS" rollout status deploy/"$APP_SVC" --timeout=300s
