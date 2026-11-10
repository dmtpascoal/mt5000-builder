# OpenWrt builds for the GL.iNet GL-MT5000 (Brume 3)

GitHub Actions workflow that builds OpenWrt for the GL-MT5000 from
OpenWrt main plus GL.iNet's device support PR
[#24237](https://github.com/openwrt/openwrt/pull/24237) (RTL8366UB DSA
switch). Nothing in the image is tied to a particular network.

## What a build uses

Every run starts from the newest code:

- **Source** (`source=latest`, default): current `openwrt/openwrt` main with
  the commits of PR #24237 rebased on top. `source=branch` builds
  `dmtpascoal/openwrt` branch `pr24237-fixes` instead.
- **Kernel** (`kernel=latest`, default): the newest stable release of the
  target's kernel series from kernel.org. If OpenWrt's patches don't apply
  to it, the run falls back to the version OpenWrt pins and says so.
  `kernel=openwrt` always uses OpenWrt's version.
- **Packages**: all feeds at their latest revision; AmneziaWG at its latest
  release tags.
- **Kernel modules** (`all_kmods`, default on): every module is built as a
  package, so drivers that are not in the image can be installed later.
  Kernel modules from the official OpenWrt repositories, or from another
  build, do not install on a custom kernel.

The versions that went into a build are in the run's summary and in
`versions.md` inside the firmware artifact.

## Running it

Actions → **Build GL-MT5000** → Run workflow. Leave *profiles* empty for the
base image (device support, LuCI, USB 3), or list profiles from
`mt5000/profiles/`, separated by spaces:

| Profile | Adds |
|---|---|
| `amneziawg` | AmneziaWG kernel module, `awg`, LuCI page |
| `amneziawg-server` | AmneziaWG server `awg0` (UDP 51820, 10.1.0.1/24, no peers) created on first boot with its own key and random obfuscation values; list with `amneziawg` |
| `wireguard` | `wireguard-tools`, LuCI page |
| `adguardhome` | AdGuard Home |
| `avahi` | avahi daemon without D-Bus (mDNS, reflector) |
| `sqm` | SQM (cake) against bufferbloat, LuCI page |
| `ddns` | Dynamic DNS (deSEC, Cloudflare, DuckDNS, Dynu, ...), LuCI page |
| `tailscale` | Tailscale, for remote access without port forwarding |
| `pbr` | Policy-based routing per device, subnet or domain, LuCI page; not with `mwan3` |
| `mwan3` | Multi-WAN failover, LuCI page; not with `pbr` |
| `diag` | `tcpdump`, `iperf3`, `htop`, `ethtool`, `ip-full` |
| `usb-storage` | USB mass storage and UAS, automount, exFAT |
| `usb-tethering` | iPhone USB tethering (`ipheth`, `usbmuxd`) and Android/dongle USB Ethernet (`cdc-ether`, `rndis`, `cdc-ncm`); add the phone's interface as a WAN in LuCI |
| `upnp` | UPnP/NAT-PMP port mapping, installed switched off |
| `adblock-fast` | DNS ad blocking through dnsmasq, LuCI page; not with `adguardhome` |
| `https-dns-proxy` | DNS over HTTPS upstream for dnsmasq, LuCI page |
| `ttyd` | Web terminal in LuCI |

A typical house: `sqm ddns tailscale diag usb-storage usb-tethering`, plus
`wireguard` or `amneziawg` for a VPN server.

A profile is a `<name>.config` with `CONFIG_PACKAGE_...=y` lines. It may also
have a `<name>.feeds` file (extra feed lines) and an executable
`<name>.post-feeds.sh` that runs after the feeds are updated.

To sign the packages of every build with the same key, add a repository
secret `APK_SIGNING_KEY`:

```
openssl ecparam -name prime256v1 -genkey -noout -out private-key.pem
gh secret set APK_SIGNING_KEY < private-key.pem
```

## Installing

- `…-squashfs-sysupgrade.bin`: flash from GL.iNet's stock web interface
  (local upgrade, **keep settings off**) or with `sysupgrade -n` from OpenWrt.
- `…-squashfs-factory.bin`: kernel and rootfs for the stock U-Boot recovery
  page.
- `…-initramfs-kernel.bin`: runs from RAM, for testing without touching the
  eMMC (needs a serial console).

After flashing, the router is at `192.168.1.1` with LAN on `lan1`/`lan2` and
WAN on the 2.5G SoC port.

Back to stock: hold reset while powering on, set your computer to
`192.168.1.2/24`, open `http://192.168.1.1` and upload GL.iNet's firmware.
