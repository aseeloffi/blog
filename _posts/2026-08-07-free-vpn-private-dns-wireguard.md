---
title: Free VPN with Private DNS over WireGuard (Proton VPN & IPv64.net)
description: >-
  Two free ways to run a WireGuard VPN with a private DNS resolver instead of
  your ISP's — Proton VPN's free tier, and a self-managed setup on IPv64.net.
date: 2026-08-07 20:00:00 +0000
categories: [Networking, Tutorial]
tags: [wireguard, vpn, dns, privacy, self-hosting]
---

## Why Combine a VPN with Private DNS

A VPN tunnel only protects the traffic that goes *through* it. If the app or OS keeps resolving hostnames with your ISP's DNS server (or leaks a DNS query outside the tunnel), your ISP — or anyone on the path — still sees every domain you visit, even while the actual traffic is encrypted. This is a classic **DNS leak**.

The fix is to make sure the `DNS` line inside the WireGuard `[Interface]` block points to a resolver you trust — either the VPN provider's own private DNS, or one you run yourself — so DNS queries travel *inside* the encrypted tunnel instead of leaking out through the regular network interface.

This post covers two free routes to get there:

- **Option 1 — Proton VPN (Free plan)**: fully managed, private DNS included automatically, zero infrastructure of your own.
- **Option 2 — IPv64.net**: free dynamic DNS + a WireGuard config generator, aimed at people who want to run their own WireGuard endpoint (e.g. a small VPS or home server) and pair it with a private DNS resolver of their choice.

> Neither option requires a credit card. Proton's free tier is a hosted VPN service; IPv64.net is DDNS + tooling for a VPN you host yourself (it also offers a hosted "VPN Gateway as a Service," which is closer to a site-to-site/remote-access VPN into your own network than an anonymizing browsing exit).
{: .prompt-tip }

## Option 1: Proton VPN Free Plan

Proton VPN's free tier gives you WireGuard configs with Proton's own DNS baked in, so there's nothing extra to configure for DNS privacy.

### 1. Create a Free Proton Account

Sign up at `account.protonvpn.com`{: .filepath } — no payment details required for the Free plan.

### 2. Generate a WireGuard Config

1. Sign in and go to **Downloads → WireGuard configuration**.
2. Name the config, choose a platform (Router/Linux/Windows/Android/iOS), and pick a server — free accounts are limited to Proton's free-tier server locations.
3. Click **Create**, then **Download** to save the `.conf`{: .filepath } file.

> On the Free plan, most advanced options (NAT-PMP, Moderate NAT, server selection beyond the free locations) are locked behind a paid plan. VPN Accelerator is the one feature Proton explicitly keeps available on Free.
{: .prompt-tip }

### 3. Import the Config

- **Windows/Linux/macOS**: install the official WireGuard client, then **Import Tunnel(s) from File** and select the downloaded `.conf`{: .filepath }.
- **Android/iOS**: install the WireGuard app, rename the file to remove any special characters Proton appends (e.g. `-US-1`), then import it and toggle the tunnel on.

The downloaded config already has `DNS = ` set to a Proton resolver in the `[Interface]` block, so once the tunnel is active, your DNS queries are automatically routed through Proton instead of your ISP.

## Option 2: IPv64.net (Free DDNS + WireGuard Config Generator)

IPv64.net is a German-run service that's genuinely free: up to 3 DynDNS subdomains, an in-browser WireGuard config generator, and a VPN Gateway product — all without a paywall. The typical use case here is different from Proton: you bring your own always-on machine (a cheap/free-tier VPS, a Raspberry Pi, an old laptop) to act as the WireGuard **server**, and IPv64 gives you a stable hostname plus the tooling to generate matching configs.

### 1. Register and Claim a Free Subdomain

Sign up at `ipv64.net`{: .filepath }, then under the DynDNS section register a subdomain such as `yourname.ipv64.net`. This gives your server a fixed hostname even if your public IP changes.

### 2. Keep the Hostname Updated

On the machine that will run as your WireGuard server, set up a cron job (or your router's built-in DDNS client) to call the update URL whenever the IP changes:

```console
$ crontab -e
```

```
*/15 * * * * curl -sSL "https://ipv64.net/nic/update?domain=yourname.ipv64.net&key=YOUR_UPDATE_TOKEN"
```

> Your **Update Token** is different from your account **API Key** — grab it from the domain's settings page, not the general API page.
{: .prompt-warning }

### 3. Generate the WireGuard Configs

Open the **WireGuard Config Generator** on IPv64.net. It runs entirely client-side in your browser — keys are generated locally and never sent to their servers. Fill in:

- **Endpoint**: `yourname.ipv64.net:51820`
- **Server/client subnet**: e.g. `10.10.0.0/24`
- **DNS**: the IP of the private resolver you want clients to use (see next step)

Download the generated server config to your VPS/home server, and the client config(s) to your devices.

### 4. Point DNS at a Private Resolver

This is the step that actually gives you *private* DNS instead of just a VPN tunnel. Two common choices:

- **Self-hosted**: run [AdGuard Home](https://adguard.com/en/adguard-home/overview.html) or Pi-hole on the same box as your WireGuard server, and set `DNS = 10.10.0.1` (the server's tunnel IP) in the client configs.
- **Third-party private resolver**: use a provider like NextDNS and set `DNS = ` to the IP they give you, the same way you'd wire it into any WireGuard `[Interface]` block.

```ini
[Interface]
PrivateKey = YOUR_CLIENT_PRIVATE_KEY
Address = 10.10.0.2/32
DNS = 10.10.0.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = yourname.ipv64.net:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

### 5. Bring the Server Up

```console
$ sudo apt install wireguard -y
$ sudo nano /etc/wireguard/wg0.conf   # paste the generated server config
$ sudo wg-quick up wg0
$ sudo systemctl enable wg-quick@wg0
```

Open UDP port `51820` on the server's firewall/security group before testing.

## Setting Up WireGuard on Your Phone (iOS & Android) with Private IPv6 DNS

Once you have a working WireGuard config from either option above, the phone side is the same regardless of whether the server is Proton's or your own IPv64-hosted box. The only change is swapping the `DNS` line for a private **IPv6** resolver instead of the provider's default — in this example, NextDNS's IPv6 anycast addresses:

```
2a07:a8c0::73:72
2a07:a8c1::73:72
```

> `2a07:a8c0::` and `2a07:a8c1::` are NextDNS's IPv6 resolver prefixes; the trailing `73:72` is the personal config ID tied to a specific NextDNS profile. Grab your own from **my.nextdns.io → Setup** before copying this into your config — using someone else's ID routes your DNS through their profile and blocklists, not yours.
{: .prompt-warning }

### 1. Install the WireGuard App

- **iOS**: WireGuard from the App Store.
- **Android**: WireGuard from the Play Store or as an APK from the official site.

### 2. Import or Create the Tunnel

If you already have a `.conf`{: .filepath } file (from Proton's download or IPv64's config generator):

- Tap **+ → Import tunnel(s) from file** and pick the file (on iOS, AirDrop or share it into the Files app first).

If you're building it manually, tap **+ → Create from scratch** and fill in the `[Interface]`/`[Peer]` fields yourself.

### 3. Set the DNS Field

In the tunnel's **Interface** section, set:

```ini
[Interface]
PrivateKey = YOUR_PHONE_PRIVATE_KEY
Address = 10.10.0.3/32
DNS = 2a07:a8c0::73:72, 2a07:a8c1::73:72

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = yourname.ipv64.net:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

The WireGuard apps on both iOS and Android accept a comma-separated `DNS` list, so listing the two addresses gives you a primary and secondary resolver, both over IPv6.

### 4. Enable On-Demand Activation (Optional, iOS)

Inside the tunnel's settings, toggle **On-Demand Activation** and choose Wi-Fi / Cellular so the VPN connects automatically instead of needing a manual tap every time.

### 5. Handle Carrier IPv6 Gaps

Some mobile carriers still don't route native IPv6, which would make the two NextDNS addresses unreachable outside the tunnel. This isn't an issue here because DNS resolution happens *inside* the WireGuard tunnel once it's up — the tunnel itself only needs the `Endpoint` (your server) to be reachable over IPv4 or IPv6, not the DNS servers directly. If queries still fail, confirm with:

```console
$ ping6 2a07:a8c0::73:72
```

run from inside the active tunnel (e.g. via Termux on Android), and check that your WireGuard server itself has outbound IPv6 connectivity to reach NextDNS.

## Setting Up WireGuard on iPhone & Android with NextDNS

If you'd rather skip self-hosting a resolver, [NextDNS](https://nextdns.io) is a solid free private-DNS option, and it gives you dedicated IPv6 addresses tied to your profile:

```
2a07:a8c0::73:72
2a07:a8c1::73:72
```

You can drop these straight into the `DNS` line of any WireGuard config — whether the server is your own IPv64.net-hosted box or another endpoint — and they'll work the same on both iPhone and Android.

### iPhone (iOS)

1. Install **WireGuard** from the App Store.
2. Get your `.conf`{: .filepath } file onto the phone — either AirDrop it from a Mac, or generate a QR code from the config generator/your server and scan it.
3. In the WireGuard app, tap **+ → Create from QR code** (or **Import from file**). The tunnel is imported using whatever DNS was already in the file — this is where you swap it for NextDNS.
4. Tap the imported tunnel to open it, then tap **Edit** in the top right.
5. Under **Interface**, tap the **DNS servers** field, clear whatever is there, and paste in:
   ```
   2a07:a8c0::73:72, 2a07:a8c1::73:72
   ```
6. Tap **Save** (top right), then toggle the tunnel on from the WireGuard app or from **Settings → VPN**.

> If you generated the config yourself, it's simpler to just set `DNS = 2a07:a8c0::73:72, 2a07:a8c1::73:72` directly in the `[Interface]` block before importing — that way there's nothing to edit on the phone afterward.
{: .prompt-tip }

### Android

1. Install **WireGuard** from the Play Store (or as an APK from the [official site](https://www.wireguard.com/install/)).
2. Tap **+ → Scan from QR code**, or **Import from file/archive** if you copied the `.conf`{: .filepath } onto the device.
3. Tap the tunnel name to edit it, and set the **DNS servers** field under the interface section to:
   ```
   2a07:a8c0::73:72, 2a07:a8c1::73:72
   ```
4. Save and flip the toggle next to the tunnel to connect.

> The official WireGuard Android app is picky about `.conf`{: .filepath } filenames — no special characters besides underscores, or the import will silently fail.
{: .prompt-warning }

### Confirming NextDNS Is Actually Being Used

Once the tunnel is up on either device, open a browser and visit:

```
https://test.nextdns.io
```

It should report that NextDNS is active and show your profile ID. If it says NextDNS isn't detected, the DNS field in the tunnel config either wasn't saved or is being overridden — recheck step 4 above.

## Verifying There's No DNS Leak

With either option's tunnel active, check that queries are actually going through the private resolver and not slipping out through your regular network:

```console
$ nslookup example.com
```

Confirm the responding server matches your VPN/DNS provider, then run a proper leak test at `https://www.dnsleaktest.com` (Extended test) or, if you're on NextDNS, visit `https://test.nextdns.io`.

> If the leak test shows your ISP's resolver instead of your VPN/private DNS, double-check the `DNS` line in `[Interface]`{: .filepath } and that the app or OS isn't overriding it with a hardcoded DNS setting (common on Android and some routers).
{: .prompt-danger }

## Which One to Pick

- **Want something that works in five minutes with no server to maintain?** Go with Proton VPN Free.
- **Want a fixed hostname for infrastructure you already run, full control over the DNS resolver, and no data-cap surprises?** Go with IPv64.net's DDNS + config generator on top of your own box.

Both get you the same end result: a WireGuard tunnel where DNS queries never touch your ISP's resolver in the clear.
