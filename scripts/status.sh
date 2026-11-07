#!/usr/bin/env bash
# Shows container state and connected peers.
docker compose ps
echo
docker exec wg-easy wg show
