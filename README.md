# Mini VPN

![WireGuard](https://img.shields.io/badge/WireGuard-88171A?logo=wireguard&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

A small self-hosted VPN to reach internal company websites from anywhere, managed through a web GUI.
Built with [WireGuard](https://www.wireguard.com/), [wg-easy](https://github.com/wg-easy/wg-easy) and Docker Compose, with optional HTTPS through Caddy.

> Only deploy this on networks you own or have explicit permission to use. Get your company's approval before exposing internal sites.

## Architecture

```
[Laptop / Phone] --WireGuard (UDP 51820)--> [VPN host: Docker + wg-easy] --> internal sites
                                                   |
                                             Web GUI (admin)
```

## Features

- Web dashboard: create, disable and delete clients, QR codes, live connection status
- Split tunnel: only company traffic goes through the VPN
- One key pair per device, revocable individually
- GUI bound to localhost by default (reach it via SSH tunnel)
- Optional automatic HTTPS (Caddy + Let's Encrypt)
- Helper scripts: firewall, backup, status

## Project structure

```
mini-vpn/
├── docker-compose.yml          # wg-easy
├── docker-compose.https.yml    # optional Caddy override
├── caddy/Caddyfile
├── scripts/                    # install-docker, firewall, backup, status
├── .env.example
└── docs/                       # screenshots, diagram
```

## Prerequisites

- A Linux host (VM, mini PC, VPS) that can reach your internal websites
- Docker and Docker Compose (`scripts/install-docker.sh` installs them on Debian/Ubuntu)
- UDP 51820 forwarded from your router/firewall to the host
- Optional: a domain name pointing to the host (for HTTPS)

## Quick start

```bash
git clone https://github.com/<you>/mini-vpn.git
cd mini-vpn
cp .env.example .env
docker compose up -d
docker compose logs -f wg-easy
```

The GUI listens on `127.0.0.1:51821` of the host. From your own machine:

```bash
ssh -L 51821:localhost:51821 user@<server-ip>
```

Then open <http://localhost:51821> and complete the first-run wizard (admin account, public host/IP, port 51820).

## Configure in the GUI

1. **Admin → Config:** set the public host (domain or public IP) and port 51820.
2. **Allowed IPs:** set your company subnets, e.g. `10.8.0.0/24, 192.168.1.0/24` (split tunnel).
3. **DNS:** set your company's internal DNS so names like `intranet.company.local` resolve.
4. **Clients → New:** one client per device. Scan the QR code with the WireGuard app or download the `.conf`.

## HTTPS (optional)

1. Point a DNS record (e.g. `vpn.example.com`) to the host and open TCP 80/443.
2. Set `VPN_DOMAIN` in `.env`.
3. Start with the override:

```bash
docker compose -f docker-compose.yml -f docker-compose.https.yml up -d
```

The GUI is then available at `https://vpn.example.com`. Consider restricting it by IP in the Caddyfile, since it is exposed to the internet.

## Firewall

```bash
sudo ./scripts/firewall.sh <your-admin-ip>
```

Opens only SSH (from your IP) and UDP 51820. Uncomment the 80/443 lines for HTTPS.

## Operations

```bash
./scripts/status.sh                          # containers + connected peers
./scripts/backup.sh                          # archive keys/configs
docker compose pull && docker compose up -d  # update
docker compose down                          # stop
```

## Troubleshooting

| Problem | Check |
|---|---|
| Client connects but no access to sites | Allowed IPs include the company subnet; host can reach the sites; IP forwarding enabled |
| Handshake never completes | UDP 51820 forwarded and open; public host in GUI is correct |
| Names don't resolve | Client DNS set to your internal DNS; DNS reachable from the host |
| Can't log in to GUI over HTTP | Keep `INSECURE=true` for local testing, or use the HTTPS override |
| `docker compose` fails on sysctls/modules | Host kernel needs WireGuard support (Linux 5.6+ includes it) |

## Security notes

- Never commit `wg-data/`, `.env` or any `.conf`/`.key` file (already in `.gitignore`).
- Keep the GUI off the public internet unless behind HTTPS and ideally IP-restricted.
- Back up `wg-data/` and store the backup encrypted.
- Remove devices from the GUI as soon as they are lost or retired.
- wg-easy settings can change between major versions, so check its official docs when upgrading.

## License

MIT
