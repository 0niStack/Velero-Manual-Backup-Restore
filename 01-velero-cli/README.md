# 01 - RustFS + Velero CLI install and setup (manual)

Backup storage is **RustFS** (S3-compatible). Edit `../config.env` first:
set `RUSTFS_ACCESS_KEY`, `RUSTFS_SECRET_KEY` and `S3_URL` (RustFS host IP, reachable from the cluster).

```bash
# 1. Start RustFS with Docker (on the storage host) + generate credentials-velero
bash 01-start-rustfs.sh

# 2. Create the bucket
bash 02-create-bucket.sh

# 3. Install the velero CLI
bash 03-install-cli.sh

# 4. Install Velero into the cluster
bash 04-install-velero.sh

# 5. Verify
bash 05-verify.sh
```

## The install command
```bash
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.13.0 \
  --bucket velero \
  --secret-file ./credentials-velero \
  --backup-location-config region=us-east-1,s3ForcePathStyle=true,s3Url=http://<RUSTFS_HOST>:9000 \
  --use-volume-snapshots=false \
  --use-node-agent \
  --wait
```
- RustFS needs `s3ForcePathStyle=true` (path-style bucket URLs).
- `--use-node-agent` is needed for PVC data (file-system) backup.

## Check
`velero backup-location get` must show `Available`. If `Unavailable`:
- `curl -I $S3_URL` from a cluster node, make sure port 9000 is open
- keys/bucket name match `config.env`
- `kubectl -n velero logs deploy/velero`
