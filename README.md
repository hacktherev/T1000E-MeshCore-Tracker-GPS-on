# HTR T1000-E MeshCore Firmware

> ⚠️ **CUSTOM COMMUNITY FIRMWARE — NOT OFFICIAL MESHCORE FIRMWARE**
>
> This is an HTR-modified build of MeshCore for the Seeed Studio SenseCAP T1000-E. It is not affiliated with, endorsed by, or maintained by MeshCore or Seeed Studio.

## Tracker behavior

- GPS enabled by default after boot/restart
- Standard build: GPS update interval 30 seconds
- Fast build: GPS update interval 10 seconds
- Buzzer enabled by default
- BLE Companion firmware
- Normal T1000-E button controls retained
- Based on official MeshCore Companion v1.17.1

## Firmware downloads

**[⬇️ Download the latest HTR T1000-E MeshCore firmware releases](https://github.com/hacktherev/T1000E-MeshCore-Tracker-GPS-on/releases/latest)**

Current release: **HTR T1000-E MeshCore Firmware v1.17.1**

Available builds:

- `T1000E-MeshCore-v1.17.1-GPS-30s.uf2` — recommended everyday tracker build
- `T1000E-MeshCore-v1.17.1-GPS-10s.uf2` — faster position updates

## Why this exists

The goal is a simple tracker that can be charged, turned on, and used without first connecting a phone or remembering to re-enable GPS. GPS remains configurable through the normal MeshCore controls, but the default state is ON.

## Battery trade-off

The 30-second build is the recommended everyday tracker configuration because it reduces GNSS activity compared with more frequent fixes. The 10-second build is intended for situations where tighter location updates are worth the additional battery use.

## Releases

All released firmware is kept in the GitHub **[Releases](https://github.com/hacktherev/T1000E-MeshCore-Tracker-GPS-on/releases)** section so the download page stays separate from the development/build files.

## Upstream

https://github.com/meshcore-dev/MeshCore
