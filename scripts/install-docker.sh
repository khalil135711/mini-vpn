#!/usr/bin/env bash
# Installs Docker + Compose plugin on Debian/Ubuntu using the official script.
set -euo pipefail
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
echo "Done. Log out and back in so the docker group applies."
