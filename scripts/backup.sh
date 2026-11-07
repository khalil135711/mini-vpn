#!/usr/bin/env bash
# Backs up WireGuard keys/configs. Keep backups private and encrypted.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p backups
FILE="backups/wg-data-$(date +%F-%H%M).tar.gz"
tar -czf "$FILE" wg-data
chmod 600 "$FILE"
echo "Backup written to $FILE"
