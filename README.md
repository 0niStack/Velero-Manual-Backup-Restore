# velero-manual-backup

Manual Velero backup and restore project, backend storage = RustFS.

- `01-velero-cli/` RustFS (Docker), bucket, velero CLI, Velero install into the cluster
- `02-namespace-backup/` demo namespace, scheduled backup (cron), manual backup, disaster, restore

Edit `config.env` first, then follow the README in each folder.
