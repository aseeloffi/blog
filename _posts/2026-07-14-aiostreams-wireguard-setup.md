---
title: AIOStreams Setup Guide with WireGuard VPN
description: >-
  Deploy AIOStreams behind a WireGuard VPN using Docker Compose and gluetun,
  including environment configuration, port forwarding, and troubleshooting notes.
date: 2026-07-14 22:23:00 +0000
categories: [Self-Hosting, Tutorial]
tags: [docker, wireguard, vpn, self-hosting]
---

## 1. Clone the Project

```console
$ cd ~
$ git clone https://github.com/Viren070/AIOStreams.git aiostreams-app
$ cd aiostreams-app
```

## 2. Install Requirements

```console
$ sudo apt update
$ sudo apt install docker.io docker-compose -y
```

## 3. Configure the Environment File

```console
$ nano .env
```

Add or edit the following, replacing the placeholders with your own values:

```
BASE_URL=http://YOUR_VM_PUBLIC_IP:3000

SECRET_KEY=your_generated_secret_key

DATABASE_URI=sqlite://./data/db.sqlite

AIOSTREAMS_AUTH=admin:your_strong_password
```

> Generate a proper random `SECRET_KEY` instead of typing one yourself:
> ```console
> $ openssl rand -hex 32
> ```
{: .prompt-tip }

## 4. Configure WireGuard

```console
$ mkdir -p ~/aiostreams-app/wireguard
$ nano ~/aiostreams-app/wireguard/wg0.conf
```

Paste the original `.conf`{: .filepath } content from your VPN provider without modifying `PostUp`/`PostDown`, e.g.:

```ini
[Interface]
PrivateKey = YOUR_WIREGUARD_PRIVATE_KEY
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = YOUR_VPN_ENDPOINT_IP:51820

PersistentKeepalive = 25
```

> Never commit a `wg0.conf`{: .filepath } with real keys to a public repository. Keep it out of version control with `.gitignore`, or replace the values above with your own before sharing this file anywhere.
{: .prompt-danger }

## 5. Configure compose.yaml

```console
$ nano ~/aiostreams-app/compose.yaml
```

Replace the entire content with this (uses `gluetun` instead of `linuxserver/wireguard`):

```yaml
services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - VPN_SERVICE_PROVIDER=custom
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=your_private_key
      - WIREGUARD_ADDRESSES=10.2.0.2/32
      - VPN_ENDPOINT_IP=your_endpoint_ip
      - VPN_ENDPOINT_PORT=51820
      - WIREGUARD_PUBLIC_KEY=your_public_key
    ports:
      - 3000:3000
    restart: unless-stopped

  aiostreams:
    image: ghcr.io/viren070/aiostreams:latest
    container_name: aiostreams
    restart: unless-stopped
    network_mode: "service:gluetun"
    env_file:
      - .env
    volumes:
      - ./data:/app/data
    depends_on:
      - gluetun
```

## 6. Start the Services

```console
$ sudo docker-compose down --remove-orphans
$ sudo docker-compose up -d
$ sleep 15
```

## 7. Verify

```console
# Confirm the server responds locally
$ curl -v http://localhost:3000

# Confirm the VPN is connected (look for "Public IP address is ...")
$ sudo docker logs gluetun --tail 30

# Confirm auth is enabled (look for "Basic auth enabled")
$ sudo docker logs aiostreams --tail 20 | grep -i auth
```

## 8. Access It

Open in your browser:

```
http://YOUR_VM_IP:3000
```

## Important Notes

- **After any `.env`{: .filepath } change**, use a full `down` then `up -d`, not just `restart` — `restart` doesn't always reload new environment variables.

  ```console
  $ sudo docker-compose down
  $ sudo docker-compose up -d
  ```

- **Opening port 3000 on Oracle Cloud**:
  Oracle Cloud Console → Compute → Instance → Subnet → Security Lists → Add Ingress Rules
  - Source CIDR: `0.0.0.0/0`
  - Destination Port Range: `3000`
  - Protocol: TCP

- **The VM's public IP may change** after the instance restarts. Always check it with:

  ```console
  $ curl ifconfig.me
  ```

  and update `BASE_URL` in `.env`{: .filepath } if it changed.

- **Don't use `linuxserver/wireguard` with `network_mode: service:wireguard` directly** — it causes a conflict between port publishing and network mode, and hangs incoming connections due to conflicting `MASQUERADE` rules. Use `gluetun` instead — it's purpose-built for this (VPN container + proper port forwarding).

- **To check the current IP that AIOStreams traffic exits from via the VPN**:

  ```console
  $ sudo docker logs gluetun | grep "Public IP"
  ```

> Keep real WireGuard keys, your `SECRET_KEY`, and your VM's public IP out of any public repository. Use placeholder values in files you plan to share, and store the real ones in a local `.env`{: .filepath } / `wg0.conf`{: .filepath } excluded via `.gitignore`.
{: .prompt-warning }
