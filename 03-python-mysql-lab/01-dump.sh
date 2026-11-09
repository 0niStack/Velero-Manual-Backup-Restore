#!/usr/bin/env bash
# SQL dump of the MySQL database -> backups/<db>-<time>.sql and backups/latest.sql
# Usage: make mysql-dump [DB=dbname]
set -euo pipefail
cd "$(dirname "$0")"
source ../config.env
mkdir -p backups

DB="${DB:-$(kubectl -n "$DB_NS" exec "$MYSQL_POD" -- printenv MYSQL_DATABASE 2>/dev/null || true)}"
[ -n "$DB" ] || { echo "Cannot detect DB name. Run: make mysql-dump DB=<name>"; exit 1; }

FILE="backups/${DB}-$(date +%Y%m%d-%H%M%S).sql"
kubectl -n "$DB_NS" exec "$MYSQL_POD" -- sh -c \
  "mysqldump -uroot -p\"\$MYSQL_ROOT_PASSWORD\" --single-transaction --routines --triggers --databases $DB" > "$FILE"

ROWS=$(grep -c "INSERT INTO" "$FILE" || true)
echo "Dump: $FILE ($(du -h "$FILE" | cut -f1), INSERT statements: $ROWS)"
[ "$ROWS" -ge 1 ] || echo "WARNING: dump has no INSERT statements (empty tables?)"
cp "$FILE" backups/latest.sql
