#!/usr/bin/env bash
# ==============================================================================
# Backup Script for Oracle Analytics Publisher Catalog & Repository
# ==============================================================================
set -euo pipefail

CONTAINER_NAME="${PUBLISHER_CONTAINER_NAME:-app-publisher}"
RUNTIME_ENGINE="${CONTAINER_ENGINE:-podman}"
BACKUP_DIR="${PROJECT_ROOT:-$(pwd)}/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/publisher_catalog_${TIMESTAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"

echo "======================================================================"
echo "💾 Backing up Analytics Publisher Catalog & Reports Repository..."
echo "======================================================================"

if ! "${RUNTIME_ENGINE}" ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  echo "Error: Container ${CONTAINER_NAME} is not running."
  exit 1
fi

echo "1. Creating archive inside container..."
"${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" sh -c "mkdir -p /tmp/bip_backup && cd /u01/oracle/user_projects/domains/bi/bidata/components/bipublisher && tar -czf /tmp/bip_catalog_${TIMESTAMP}.tar.gz repository"

echo "2. Extracting backup archive to host: ${BACKUP_FILE}..."
"${RUNTIME_ENGINE}" cp "${CONTAINER_NAME}:/tmp/bip_catalog_${TIMESTAMP}.tar.gz" "${BACKUP_FILE}"
"${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" rm -f "/tmp/bip_catalog_${TIMESTAMP}.tar.gz"

echo "======================================================================"
echo "✅ Publisher Catalog backup saved successfully:"
echo "   ${BACKUP_FILE}"
echo "======================================================================"
