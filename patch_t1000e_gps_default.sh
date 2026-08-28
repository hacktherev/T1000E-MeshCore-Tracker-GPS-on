#!/usr/bin/env bash
set -euo pipefail

# Run from the root of an official MeshCore checkout at companion-v1.17.1.
# Argument 1: desired GPS interval in seconds (30 or 10).
INTERVAL="${1:-30}"
FILE="examples/companion_radio/NodePrefs.h"

case "$INTERVAL" in
  10|30) ;;
  *) echo "Usage: $0 10|30" >&2; exit 2 ;;
esac

python3 - "$FILE" "$INTERVAL" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
interval = int(sys.argv[2])
s = p.read_text()

old1 = 'uint8_t gps_enabled = 0;      // GPS enabled flag (0=disabled, 1=enabled)'
new1 = 'uint8_t gps_enabled = 1;      // GPS enabled by default (0=disabled, 1=enabled)'
old2 = 'uint32_t gps_interval = 0;     // GPS read interval in seconds'
new2 = f'uint32_t gps_interval = {interval};    // GPS read interval in seconds; tracker default'

if old1 not in s:
    raise SystemExit('gps_enabled default line not found; upstream source changed')
if old2 not in s:
    raise SystemExit('gps_interval default line not found; upstream source changed')

s = s.replace(old1, new1, 1).replace(old2, new2, 1)
p.write_text(s)
PY
