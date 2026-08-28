#!/usr/bin/env bash
set -euo pipefail

# HTR T1000-E Auto Tracker BETA for MeshCore Companion v1.17.1.
# Behavior:
#   - GPS defaults remain enabled by the tracker build.
#   - After the first real GPS fix, send one flood-routed advert with live GPS.
#   - Every 4 hours, send another flood-routed advert only if the position
#     has moved significantly from the last advertised position.
#   - Telemetry behavior is untouched.
#   - Significant movement threshold is 100 meters.

python3 - <<'PY'
from pathlib import Path

h = Path('examples/companion_radio/MyMesh.h')
c = Path('examples/companion_radio/MyMesh.cpp')

hs = h.read_text()
cs = c.read_text()

# Add the beta method declaration.
needle = '  bool advert();\n'
insert = needle + '  void autoTrackerLoop();\n'
if 'void autoTrackerLoop();' not in hs:
    if needle not in hs:
        raise SystemExit('MyMesh.h: advert declaration not found')
    hs = hs.replace(needle, insert, 1)

# Add beta state fields. v1.17.1 uses three spaces before send_unscoped.
needle = '  bool send_unscoped;   // force un-scoped flood (instead of using send_scope)\n'
insert = needle + '''  // HTR Auto Tracker BETA state\n  bool auto_tracker_have_position;\n  double auto_tracker_last_lat;\n  double auto_tracker_last_lon;\n  unsigned long auto_tracker_next_check;\n'''
if 'auto_tracker_have_position' not in hs:
    if needle not in hs:
        raise SystemExit('MyMesh.h: send_unscoped field not found')
    hs = hs.replace(needle, insert, 1)

# Initialize state in constructor.
needle = '  send_unscoped = false;\n'
insert = needle + '''  auto_tracker_have_position = false;\n  auto_tracker_last_lat = 0.0;\n  auto_tracker_last_lon = 0.0;\n  auto_tracker_next_check = 0;\n'''
if 'auto_tracker_next_check = 0;' not in cs:
    if needle not in cs:
        raise SystemExit('MyMesh.cpp: constructor state marker not found')
    cs = cs.replace(needle, insert, 1)

# Insert the tracker implementation before loop().
marker = 'void MyMesh::loop() {\n'
method = r'''// HTR Auto Tracker BETA: maintain a useful last-known GPS location\n// without turning the T1000-E into a frequent mesh beacon.\nvoid MyMesh::autoTrackerLoop() {\n#if ENV_INCLUDE_GPS == 1\n  static const unsigned long CHECK_INTERVAL_MS = 4UL * 60UL * 60UL * 1000UL;\n  static const double SIGNIFICANT_MOVE_METERS = 100.0;\n\n  if (!sensors.getLocationProvider() || !sensors.getLocationProvider()->isValid()) {\n    return;\n  }\n\n  const double lat = sensors.node_lat;\n  const double lon = sensors.node_lon;\n\n  // Ignore an invalid/uninitialized coordinate.\n  if (lat == 0.0 && lon == 0.0) {\n    return;\n  }\n\n  // First real GPS fix after boot: immediately publish one flood advert.\n  if (!auto_tracker_have_position) {\n    mesh::Packet* pkt = createSelfAdvert(_prefs.node_name, lat, lon);\n    if (pkt) {\n      TransportKey default_scope;\n      memcpy(&default_scope.key, _prefs.default_scope_key, sizeof(default_scope.key));\n      sendFloodScoped(default_scope, pkt, 0);\n      auto_tracker_last_lat = lat;\n      auto_tracker_last_lon = lon;\n      auto_tracker_have_position = true;\n      auto_tracker_next_check = millis() + CHECK_INTERVAL_MS;\n      MESH_DEBUG_PRINTLN("HTR Auto Tracker BETA: initial GPS flood advert sent");\n    }\n    return;\n  }\n\n  if (!millisHasNowPassed(auto_tracker_next_check)) {\n    return;\n  }\n  auto_tracker_next_check = millis() + CHECK_INTERVAL_MS;\n\n  // Equirectangular approximation is more than adequate for a 100 m threshold.\n  const double meters_per_degree = 111320.0;\n  const double lat_mid_rad = ((lat + auto_tracker_last_lat) * 0.5) * 0.017453292519943295;\n  const double dlat = (lat - auto_tracker_last_lat) * meters_per_degree;\n  const double dlon = (lon - auto_tracker_last_lon) * meters_per_degree * cos(lat_mid_rad);\n  const double distance_m = sqrt((dlat * dlat) + (dlon * dlon));\n\n  if (distance_m < SIGNIFICANT_MOVE_METERS) {\n    MESH_DEBUG_PRINTLN("HTR Auto Tracker BETA: no significant movement (%.1f m)", distance_m);\n    return;\n  }\n\n  mesh::Packet* pkt = createSelfAdvert(_prefs.node_name, lat, lon);\n  if (pkt) {\n    TransportKey default_scope;\n    memcpy(&default_scope.key, _prefs.default_scope_key, sizeof(default_scope.key));\n    sendFloodScoped(default_scope, pkt, 0);\n    auto_tracker_last_lat = lat;\n    auto_tracker_last_lon = lon;\n    MESH_DEBUG_PRINTLN("HTR Auto Tracker BETA: movement %.1f m, flood advert sent", distance_m);\n  }\n#endif\n}\n'''
if 'void MyMesh::autoTrackerLoop()' not in cs:
    if marker not in cs:
        raise SystemExit('MyMesh.cpp: loop marker not found')
    cs = cs.replace(marker, method + marker, 1)

# Call tracker logic from the normal loop without touching telemetry behavior.
needle = 'void MyMesh::loop() {\n  BaseChatMesh::loop();\n'
insert = 'void MyMesh::loop() {\n  BaseChatMesh::loop();\n\n  autoTrackerLoop();\n'
if '  autoTrackerLoop();' not in cs:
    if needle not in cs:
        raise SystemExit('MyMesh.cpp: loop body marker not found')
    cs = cs.replace(needle, insert, 1)

h.write_text(hs)
c.write_text(cs)
PY

grep -n "autoTrackerLoop\|auto_tracker_" examples/companion_radio/MyMesh.h examples/companion_radio/MyMesh.cpp
