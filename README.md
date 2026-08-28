# HTR T1000-E MeshCore Firmware

> ⚠️ **CUSTOM COMMUNITY FIRMWARE — NOT OFFICIAL MESHCORE FIRMWARE**
>
> This is an HTR-modified build of MeshCore for the Seeed Studio SenseCAP T1000-E. It is not affiliated with, endorsed by, or maintained by MeshCore or Seeed Studio.

## What this is

Custom MeshCore Companion firmware for the **Seeed Studio T1000-E** with GPS enabled by default. The project is intended for tracking dogs, children, equipment, and other objects over a MeshCore network without having to reconnect a phone and manually enable GPS after every charge or restart.

All firmware in this repository is based on **MeshCore Companion v1.17.1**.

## Firmware downloads

**[⬇️ Download the latest HTR T1000-E MeshCore firmware releases](https://github.com/hacktherev/T1000E-MeshCore-Tracker-GPS-on/releases/latest)**

### Stable firmware

**HTR T1000-E MeshCore Firmware v1.17.1**

- `T1000E-MeshCore-v1.17.1-GPS-30s.uf2` — recommended everyday tracker build; GPS update interval is 30 seconds.
- `T1000E-MeshCore-v1.17.1-GPS-10s.uf2` — faster GPS updates when more frequent position updates are worth the additional battery use.

Both stable builds have:

- GPS enabled by default after boot/restart
- Buzzer enabled by default
- BLE Companion firmware
- Normal T1000-E button controls retained
- No erase intended to be required for normal installation

The stable v1.17.1 firmware has been tested on a T1000-E and confirmed working.

## 🧪 Auto Tracker BETA

> ⚠️ **BETA / WORK IN PROGRESS — EXPERIMENTAL**
>
> The Auto Tracker build is a custom experimental addition on top of the tested HTR v1.17.1 GPS-enabled firmware. It is intended to maintain a useful **last-known GPS location** on the MeshCore network without generating unnecessary advertisement traffic.

**[🧪 Download the HTR Auto Tracker BETA release](https://github.com/hacktherev/T1000E-MeshCore-Tracker-GPS-on/releases/tag/t1000e-auto-advert)**

### Auto Tracker behavior

#### 🛰️ GPS

- GPS is enabled automatically.
- GPS update interval is **30 seconds**.
- GPS operation and normal telemetry behavior are otherwise left as in the underlying MeshCore firmware.

#### 🚀 After boot

The tracker does **not** immediately advertise its configured/default location.

Instead:

1. The T1000-E boots with GPS enabled.
2. The firmware waits for a genuine valid GPS fix.
3. Once a valid GPS position is available, it sends **one flood-routed self advertisement containing the live GPS position**.
4. That position becomes the reference point for future movement checks.

#### ⏱️ Normal operation

After the initial GPS advertisement:

- The firmware checks the GPS position every **4 hours**.
- It compares the current position with the **last advertised position**.
- If the tracker has moved **100 meters or more**, it sends a new flood-routed advertisement containing the updated GPS position.
- If the tracker has not moved significantly, **no advertisement is sent**.
- The four-hour check itself does **not** cause an advertisement.
- The Auto Tracker feature does **not** generate periodic zero-hop location advertisements.
- It does **not** advertise every GPS update.

In other words, a stationary tracker can remain quiet for days. A meaningful change in location causes the next four-hour check to publish a new last-known position.

### 📡 Why the Auto Tracker exists

MeshCore telemetry can provide current information while the tracker is reachable. When live telemetry or the direct connection is unavailable, however, the network may only have the tracker's last advertised location.

The Auto Tracker BETA is designed to keep that last-known location useful while being deliberately conservative about mesh traffic.

The intended behavior is:

**GPS frequently knows where the tracker is → telemetry remains available normally → advertisements are rare and movement-based.**

### 🔊 Buzzer

The buzzer remains enabled by default, retaining normal MeshCore message notification behavior.

### 🔋 Battery considerations

The Auto Tracker BETA keeps GPS enabled and therefore may use more battery than a configuration with GPS disabled or used less frequently.

The advertisement feature itself is intentionally infrequent, but actual battery life depends on GPS reception, radio activity, mesh traffic, temperature, battery condition, and movement.

## ⚠️ BETA warnings

This is **experimental firmware**. The automatic location-advertising feature is a work in progress and should be tested before being relied upon for safety-critical or otherwise important tracking.

Important points:

- A displayed advertised position is a **last-known advertised GPS position**, not necessarily the tracker's current position.
- Live telemetry should be used when a current position is required and the tracker is reachable.
- GPS may take time to obtain a fix, especially indoors or where satellite visibility is poor.
- The Auto Tracker currently uses a **100-meter significant-movement threshold**.
- The Auto Tracker currently uses a **4-hour movement-check interval**.
- The first flood advertisement occurs only after a valid GPS position is obtained.
- The Auto Tracker does not intentionally change the normal telemetry refresh behavior.

## 🔄 Installation

The firmware is provided as a `.uf2` file for the T1000-E.

**No erase is intended to be required for normal installation.**

1. Download the desired `.uf2` from the [Releases](https://github.com/hacktherev/T1000E-MeshCore-Tracker-GPS-on/releases) page.
2. Put the T1000-E into DFU/bootloader mode.
3. Connect it to the computer.
4. The T1000-E should appear as a removable drive.
5. Drag the `.uf2` file onto the T1000-E drive.
6. Allow the device to reboot.

Do not disconnect the device while the firmware is being transferred.

If you are testing the BETA and encounter problems, the stable **GPS-30s** release is available as a known-good fallback.

## 📦 Release summary

| Build | GPS | Auto Tracker | Advert behavior | Status |
|---|---:|---:|---|---|
| GPS-30s | 30 sec | No | Normal MeshCore | **Stable** |
| GPS-10s | 10 sec | No | Normal MeshCore | **Stable** |
| AutoTracker-BETA | 30 sec | Yes | Initial flood after GPS fix; then flood only after ≥100 m movement at 4-hour checks | **BETA** |

## Upstream

This project is based on the MeshCore project:

https://github.com/meshcore-dev/MeshCore

**MeshCore and Seeed Studio are not affiliated with this custom HTR firmware.**
