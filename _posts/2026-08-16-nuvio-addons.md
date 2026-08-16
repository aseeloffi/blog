---
title: Nuvio Addons
description: How to install addons in Nuvio with ready-to-copy manifest links.
author: aseel
date: 2026-08-16 20:00:00 +0300
categories: [Nuvio, Streaming]
tags: [nuvio, stremio, addons, streaming]
sitemap: false
noindex: true
---

Nuvio is an open-source media player built with Kotlin Multiplatform, available on Android, iOS, and Android TV. It runs on the same addon ecosystem as Stremio — any Stremio-compatible addon works in Nuvio.

When you first open the app you'll see a black screen saying "No active addons" — that's expected. The app ships empty and needs addons to load any content.

---

## How to Install an Addon

1. Open Nuvio
2. Go to **Settings → Content & Discovery → Addons**
3. Tap **Add Addon**
4. Paste the `manifest.json` URL into the field
5. Tap **Install**

---

## Addons

### Xperience

A customizable catalog addon. You pick the rows shown on your home screen — Trending, genre lists, Trakt watchlists, AI-generated picks, and more.

```
https://xperience-app.com/manifest/583b13e5-561b-4a7c-a69b-b0119199dd75/eyJhbGciOiJIUzI1NiJ9.eyJwaWQiOiI1ODNiMTNlNS01NjFiLTRhN2MtYTY5Yi1iMDExOTE5OWRkNzUiLCJraWQiOiI0YWIwMTcyMC05MWM5LTRkMjYtYWE0NS1kZjRhODlhOTk0MzMiLCJzY29wZSI6Im1hbmlmZXN0Iiwic3ViIjoiM2FhYzZkODAtYTMzZS00ZDUxLWI4OTItYzhjNWU4NWM4ZWRiIiwiaWF0IjoxNzg2OTEwMzA3fQ.Gh6ecY2xCBZMDpyomUkmZOBat-5UROYS2xgLNsVO2p4/manifest.json
```

---

### ShowBox

A movies and series addon with a solid library of content.

```
https://showbox.codiv.dpdns.org/%7B%22cookie%22%3A%22eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3ODQwODgxMTEsIm5iZiI6MTc4NDA4ODExMSwiZXhwIjoxODE1MTkyMTMxLCJkYXRhIjp7InVpZCI6MjEwNzQ5OCwidG9rZW4iOiI2MTQ1NmYxMWVjNDg1M2VlYTFjYTYyZDQ2MmM4MTkzYiJ9fQ.EHeUqtBqpSxYHTL_ZVrLNejamOreArmek0PwM5Y9CPQ%22%7D/manifest.json
```

---

### AIOStreams

An all-in-one streams aggregator that pulls from multiple sources and supports TorBox and other debrid services.

```
https://aiostreams.fortheweak.cloud/stremio/774a553b-e374-41b7-bedb-fade68dc5cd7/eyJpIjoiYnFlTXdVS3VGeGl2M0gvbFdVa0RDdz09IiwiZSI6ImlEOTMyakdiUEJUZUtiNUFpZ3RTSFE9PSIsInQiOiJhIn0/manifest.json
```

---

### Nova Streamz

An additional streaming sources addon.

```
https://nova-streamz.vercel.app/manifest.json
```

---


