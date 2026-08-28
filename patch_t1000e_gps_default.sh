#!/usr/bin/env bash
set -euo pipefail

# Apply tracker defaults to the selected MeshCore Companion release.
# Argument 1: desired GPS interval in seconds (30 or 10).
INTERVAL="${1:-30}"
FILE="examples/companion_radio/NodePrefs.h"

case "$INTERVAL" in
  10|30) ;;
  *) echo "Usage: $0 10|30" >&2; exit 2 ;;
esac

python3 - "$FILE" "$INTERVAL" <<'PY'
from pathlib import Path
import re
import sys

p = Path(sys.argv[1])
interval = int(sys.argv[2])
s = p.read_text()

# MeshCore v1.17.1 changed whitespace/alignment compared with some earlier
# releases. Match the declarations rather than their exact spacing.
gps_enabled_pattern = r'(uint8_t\s+gps_enabled\s*=\s*)\d+(\s*;[^\n]*)'
gps_interval_pattern = r'(uint32_t\s+gps_interval\s*=\s*)\d+(\s*;[^\n]*)'
buzzer_pattern = r'(uint8_t\s+buzzer_quiet\s*=\s*)\d+(\s*;[^\n]*)'

s, n1 = re.subn(gps_enabled_pattern, r'\g<1>1\g<2>', s, count=1)
s, n2 = re.subn(gps_interval_pattern, rf'\g<1>{interval}\g<2>', s, count=1)
# Explicitly keep the buzzer enabled by default (0 = not quiet).
s, n3 = re.subn(buzzer_pattern, r'\g<1>0\g<2>', s, count=1)

if n1 != 1:
    raise SystemExit('gps_enabled declaration not found; upstream source changed')
if n2 != 1:
    raise SystemExit('gps_interval declaration not found; upstream source changed')
if n3 != 1:
    raise SystemExit('buzzer_quiet declaration not found; upstream source changed')

p.write_text(s)
PY
