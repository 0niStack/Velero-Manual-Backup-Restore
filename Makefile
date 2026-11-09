SHELL := /bin/bash
.DEFAULT_GOAL := help
export BACKUP DB FORCE

V1 := 01-velero-cli
V2 := 02-namespace-backup
V3 := 03-python-mysql-lab

help: ## Show this help
	@echo "Usage: make <target> [BACKUP=name] [DB=name] [FORCE=1]"; echo
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "}{printf "  %-24s %s\n",$$1,$$2}'

# ---------------- 01: RustFS + Velero ----------------
setup: rustfs-up bucket cli velero-install velero-verify ## 01: everything (RustFS, bucket, CLI, Velero)

rustfs-up: ## 01: start RustFS (Docker) + write credentials
	@bash $(V1)/01-start-rustfs.sh

bucket: ## 01: create the velero bucket in RustFS
	@bash $(V1)/02-create-bucket.sh

cli: ## 01: install the velero CLI
	@bash $(V1)/03-install-cli.sh

velero-install: ## 01: install Velero into the cluster (low CPU/mem requests)
	@bash $(V1)/04-install-velero.sh

velero-verify: ## 01: check Velero + backup location (must be Available)
	@bash $(V1)/05-verify.sh

velero-lower-resources: ## 01: fix Pending "Insufficient cpu" on installed Velero
	@bash $(V1)/07-lower-resources.sh

velero-uninstall: ## 01: remove Velero from the cluster
	@bash $(V1)/06-uninstall.sh

# ---------------- 02: demo namespace ----------------
demo-deploy: ## 02: deploy demo-app namespace (nginx + PVC)
	@bash $(V2)/01-deploy-app.sh

demo-schedule: ## 02: create the daily Velero schedule
	@bash $(V2)/02-create-schedule.sh

demo-backup: ## 02: manual backup now
	@bash $(V2)/03-backup-now.sh

demo-disaster: ## 02: delete the demo namespace
	@bash $(V2)/04-simulate-disaster.sh

demo-restore: ## 02: restore (latest schedule backup, or BACKUP=name)
	@bash $(V2)/05-restore.sh $(BACKUP)

demo-verify: ## 02: verify restored data
	@bash $(V2)/06-verify.sh

# ---------------- 03: Python-MySQL-Lab ----------------
mysql-dump: ## 03: SQL dump of MySQL (DB=name if not detected)
	@bash $(V3)/01-dump.sh

mysql-schedule: ## 03: daily Velero schedule for myapp + mydb
	@bash $(V3)/02-create-schedule.sh

mysql-backup: ## 03: SQL dump + Velero backup of myapp and mydb
	@bash $(V3)/03-backup.sh

mysql-disaster: ## 03: delete myapp + mydb (asks first, FORCE=1 skips)
	@bash $(V3)/04-disaster.sh

mysql-restore: ## 03: Velero restore + load SQL dump + restart app
	@bash $(V3)/05-restore.sh

mysql-verify: ## 03: check pods, network policies, GET /items
	@bash $(V3)/06-verify.sh

mysql-test: ## 03: full cycle: backup -> disaster -> restore -> verify
	@$(MAKE) mysql-backup
	@$(MAKE) mysql-disaster FORCE=1
	@$(MAKE) mysql-restore
	@$(MAKE) mysql-verify

# ---------------- common ----------------
status: ## Velero backups, restores, schedules
	@velero backup get; echo; velero restore get; echo; velero schedule get

.PHONY: help setup rustfs-up bucket cli velero-install velero-verify velero-lower-resources velero-uninstall \
        demo-deploy demo-schedule demo-backup demo-disaster demo-restore demo-verify \
        mysql-dump mysql-schedule mysql-backup mysql-disaster mysql-restore mysql-verify mysql-test status
