---
title: Turning an Android Phone into a Linux USB Host
description: >-
Force a rooted Android phone’s USB port into host mode, bind an iPhone into
usbmux, and run a full Debian environment against it via Termux and
proot-distro — no computer required.
date: 2026-07-20 12:00:00 +0000
categories: [Self-Hosting, Tutorial]
tags: [android, linux, usb, ios, termux]
---

This walkthrough is based on a real setup done on a rooted Android phone, connecting it to an iPhone and running real Linux tools directly on it.

## The Core Idea

An Android phone normally operates in **Device Mode** — meaning if you plug it into a computer, the computer is in control and the phone is the peripheral, just like a USB flash drive.

What we want is the opposite: the phone acting as a **Host** — in control of, and able to recognize, any second USB device plugged into it (like an iPhone). That opens the door to running actual Linux tools against the phone’s real USB port.

The whole process breaks down into four stages:

1. Installing Termux and proot-distro
1. Switching the USB port from Device mode to Host mode
1. Forcing the connected iPhone into usbmux protocol mode
1. Running a full Debian environment inside Android, bound to the real USB port

> This requires a **rooted** Android device (e.g. via Magisk) with root access granted to Termux.
> {: .prompt-warning }

## 1. Install Termux and proot-distro

Install Termux from **F-Droid**, not the Play Store — the Play Store build is outdated and no longer maintained.

```console
$ pkg update && pkg upgrade
$ pkg install proot-distro
$ proot-distro install debian
```

This gives you Termux for the Android-level commands, and a Debian container ready for the actual Linux tooling.

## 2. Enable Host Mode (OTG)

```console
$ su -c 'echo "dfp" > /sys/devices/platform/soc/1c40000.qcom,spmi/spmi-0/spmi0-02/1c40000.qcom,spmi:qcom,pmi632@2:qcom,qpnp-smb5/dual_role_usb/otg_default/mode'
$ su -c 'echo "host" > /sys/devices/platform/soc/4e00000.ssusb/mode'
```

These write directly to kernel sysfs files controlling the USB chip — in this case a Qualcomm PMI632 paired with an SSUSB controller.

- `dfp` stands for **Downstream Facing Port**: the phone becomes the power source and controller.
- `host` forces the USB controller to operate as a host instead of a peripheral.

Normally this happens automatically with a genuine OTG cable, but some custom Android skins (like MIUI) block or disable it by default, so it needs to be forced manually.

> The exact paths (like `1c40000.qcom,spmi...`) depend on your chipset. Find the right one on your device by searching inside `/sys/devices/platform/soc/`{: .filepath } for folders containing `dual_role_usb` or `*usb*/mode`.
> {: .prompt-tip }

## 3. Force the iPhone into usbmux Mode

```console
$ for dev in /sys/bus/usb/devices/*; do
    if [ -f "$dev/idVendor" ] && grep -q "05ac" "$dev/idVendor"; then
      echo 4 > "$dev/bConfigurationValue" && echo "Done for $dev"
    fi
  done
$ usbmuxd -f -v
```

Every connected USB device has a unique **Vendor ID** identifying its manufacturer — `05ac` is Apple’s. This loop scans all connected devices and finds the iPhone specifically.

It then writes `4` to `bConfigurationValue`. Apple devices expose several possible USB configurations over the same connection — charge-only, PTP/camera, and **usbmux** (the same protocol iTunes and Xcode use to talk to an iPhone). Configuration 4 is the one that activates usbmux.

The last line starts **usbmuxd**, the daemon responsible for actually speaking that protocol to the iPhone. Without it, the iPhone is physically connected but nothing can communicate with it at the software level.

## 4. Bind a Debian Environment to Real USB

```console
$ export PATH=/data/data/com.termux/files/usr/bin:$PATH
$ proot-distro login debian --shared-tmp --bind /dev/bus/usb:/dev/bus/usb
```

Android itself doesn’t ship the tooling needed for iOS signing workflows (things like `pymobiledevice3`{: .filepath } or `SideServer-for-Linux`{: .filepath }). Logging into the Debian container gives you a real Debian userland running inside Termux, without needing true root or a real chroot (it relies on `ptrace` under the hood).

The critical part of this command is:

```
--bind /dev/bus/usb:/dev/bus/usb
```

This binds Android’s real USB devices directory directly into the Debian environment, so Debian can actually “see” the iPhone physically connected to the phone — not just Android’s own kernel.

## Putting It All Together

After all four stages, you effectively have:

- Termux + a Debian container ready for real Linux tooling
- A USB port running in Host mode instead of Device mode
- An iPhone forced into usbmux mode with a daemon actively speaking to it
- A full Debian environment with direct access to that same USB port

The end result is a genuine pocket-sized Linux machine with a working USB port, capable of running any Linux tool that talks to devices over USB.

> Keep root access and OTG mode limited to when you actually need them — running your phone’s USB controller in host mode full-time isn’t necessary and can interfere with normal charging/data behavior.
> {: .prompt-danger }