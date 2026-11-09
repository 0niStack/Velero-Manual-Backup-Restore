# 02 - Namespace backup, schedule (cron) and restore (manual)

Prerequisite: Velero installed and `velero backup-location get` shows `Available` (see `../01-velero-cli`).

## Flow
```bash
# 1. Deploy the demo namespace (nginx + PVC + ConfigMap + Service)
bash 01-deploy-app.sh

# 2. Create the scheduled backup (daily 02:00, TTL 30d)
bash 02-create-schedule.sh

# 3. Take a backup now, manually
bash 03-backup-now.sh

# 4. Simulate a disaster: delete the namespace
bash 04-simulate-disaster.sh

# 5. Restore
bash 05-restore.sh                     # latest backup from the schedule
bash 05-restore.sh demo-app-manual-... # or a specific backup name

# 6. Verify data came back
bash 06-verify.sh
```

## Useful raw commands
```bash
# Schedule
velero schedule get
velero schedule describe demo-app-daily
velero schedule pause demo-app-daily
velero schedule unpause demo-app-daily
velero schedule delete demo-app-daily

# Create schedule from CLI instead of YAML
velero schedule create demo-app-daily \
  --schedule="0 2 * * *" \
  --include-namespaces demo-app \
  --default-volumes-to-fs-backup \
  --ttl 720h0m0s

# Trigger the schedule once immediately
velero backup create --from-schedule demo-app-daily --wait

# Backups
velero backup get
velero backup describe <name> --details
velero backup logs <name>
velero backup delete <name>

# Restores
velero restore get
velero restore describe <restore-name> --details
velero restore logs <restore-name>

# Restore into a different namespace
velero restore create --from-backup <name> --namespace-mappings demo-app:demo-app-restored

# Restore only specific resources
velero restore create --from-backup <name> --include-resources deployments,services,configmaps
```

## Notes
- PVC data is backed up with the node-agent (file-system backup), enabled by `defaultVolumesToFsBackup: true`.
- A restore skips resources that already exist. Delete the namespace first (step 4) or use a namespace mapping.
- Schedule cron is evaluated in UTC by default.
