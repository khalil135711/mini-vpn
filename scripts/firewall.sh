#!/usr/bin/env bash
# Basic UFW firewall for the VPN host (Debian/Ubuntu).
# Usage: sudo ./scripts/firewall.sh [ADMIN_IP]
# ADMIN_IP (optional): only this IP may reach SSH.
set -euo pipefail
ADMIN_IP="${1:-}"

ufw --force reset
ufw default deny incoming
ufw default allow outgoing

if [ -n "$ADMIN_IP" ]; then
  ufw allow from "$ADMIN_IP" to any port 22 proto tcp
else
  ufw allow 22/tcp
fi

ufw allow 51820/udp   # WireGuard
# Uncomment if you use the HTTPS override (Caddy):
# ufw allow 80/tcp
# ufw allow 443/tcp

ufw --force enable
ufw status verbose
echo "Note: Docker publishes ports via iptables and can bypass UFW."
echo "That is why the GUI port is bound to 127.0.0.1 in docker-compose.yml."
