#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export XDG_DATA_HOME=/workspace/.local/share
export XDG_CONFIG_HOME=/workspace/.config
export XDG_CACHE_HOME=/workspace/.cache
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" build/web
case "${1:-test}" in
  test)
    godot --headless --path . --script tests/combat_test.gd
    godot --headless --path . --script tests/movement_test.gd
    godot --headless --path . --script tests/rewards_test.gd
    godot --headless --path . --script tests/tactics_test.gd
    godot --headless --path . --script tests/targeting_test.gd
    ;;
  build) godot --headless --path . --export-debug Web build/web/index.html ;;
  serve) python3 -m http.server 8000 --bind 0.0.0.0 --directory build/web ;;
  *) echo 'Usage: scripts/dev.sh [test|build|serve]'; exit 2 ;;
esac
