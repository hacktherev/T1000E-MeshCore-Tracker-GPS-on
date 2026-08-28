# T1000-E MeshCore Tracker — GPS On

Custom MeshCore firmware configuration for the Seeed Studio SenseCAP T1000-E.

## Tracker behavior

- GPS enabled by default after boot/restart
- Standard build: GPS update interval 30 seconds
- Fast build: GPS update interval 10 seconds
- Buzzer enabled by default
- BLE Companion firmware
- Normal T1000-E button controls retained
- Based on official MeshCore Companion v1.17.1

## Why this exists

The goal is a simple tracker that can be charged, turned on, and used without first connecting a phone or remembering to re-enable GPS. GPS remains configurable through the normal MeshCore controls, but the default state is ON.

## Battery trade-off

The 30-second build is the recommended everyday tracker configuration because it reduces GNSS activity compared with more frequent fixes. The 10-second build is intended for situations where tighter location updates are worth the additional battery use.

## Firmware builds

The GitHub Actions workflow builds both T1000-E BLE Companion variants from the official MeshCore v1.17.1 source:

- `T1000E Tracker GPS 30s`
- `T1000E Tracker GPS 10s`

The buzzer is intentionally left enabled so incoming messages can alert the wearer/handler.

## Upstream

https://github.com/meshcore-dev/MeshCore
