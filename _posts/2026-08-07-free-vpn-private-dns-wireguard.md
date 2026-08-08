---
title: Free VPN with Private DNS on iPhone & Android (WireGuard)
description: >-
  A simple phone-only guide to running WireGuard with a private DNS (NextDNS)
  instead of your carrier's — using Proton VPN or IPv64.net.
date: 2026-08-07 20:00:00 +0000
categories: [Networking, Tutorial]
tags: [wireguard, vpn, dns, privacy, ios, android]
---

## Why This Matters

A VPN encrypts your traffic, but if your phone still uses your carrier's DNS to look up websites, your carrier can still see every site you visit. Setting a **private DNS** (like NextDNS) inside your WireGuard tunnel closes that gap.

This guide only covers phones — iPhone and Android — with two free ways to get a WireGuard tunnel, plus how to add NextDNS as your DNS.

## Step 1: Get a Free WireGuard Config

Pick one:

### Proton VPN (Free)
1. Sign up for free at `account.protonvpn.com`{: .filepath }.
2. Go to **Downloads → WireGuard configuration**.
3. Pick a server, tap **Create**, then **Download** the `.conf`{: .filepath } file.

### IPv64.net
1. Sign up for free at `ipv64.net`{: .filepath }.
2. Open the **WireGuard Config Generator** on the site.
3. Fill in the basic fields and generate your config.
4. Download the client `.conf`{: .filepath } file.

> Either way, you end up with one `.conf`{: .filepath } file (or a QR code) — that's all you need for the next step.
{: .prompt-tip }

## Step 2: Install WireGuard on Your Phone

- **iPhone**: install **WireGuard** from the App Store.
- **Android**: install **WireGuard** from the Play Store.

## Step 3: Import the Config

- If you have the file on your phone: tap **+ → Import from file/archive**.
- If you have it open on a computer: tap **+ → Scan from QR code** and scan it.

Give the tunnel a name and save it.

## Step 4: Set NextDNS as the DNS

Once the tunnel is imported:

### iPhone
1. Tap the tunnel to open it, then tap **Edit** (top right).
2. Under **Interface**, tap **DNS servers**, clear the field, and paste:
   ```
   2a07:a8c0::73:72, 2a07:a8c1::73:72
   ```
3. Tap **Save**.

### Android
1. Tap the tunnel, then tap the pencil/edit icon.
2. Find the **DNS servers** field under the interface section, clear it, and paste:
   ```
   2a07:a8c0::73:72, 2a07:a8c1::73:72
   ```
3. Save.

## Step 5: Connect and Check

Turn the tunnel on with the toggle next to its name.

To confirm NextDNS is actually being used, open your phone's browser and go to:

```
https://test.nextdns.io
```

It should say NextDNS is active. If it doesn't, go back to Step 4 and make sure the DNS servers field was saved correctly.

> If your carrier or Wi-Fi blocks IPv6, NextDNS won't be reachable. Switch to a Wi-Fi network or mobile data that supports IPv6, or ask NextDNS support for an IPv4 alternative.
{: .prompt-warning }