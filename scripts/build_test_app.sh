#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/dist/GPUUsage.app"

BUILD_CONFIGURATION="${BUILD_CONFIGURATION:-debug}" \
SKIP_DMG=1 \
"$ROOT_DIR/scripts/package_app.sh"

echo "Test app bundle: $APP_PATH"
echo "Open it with: open \"$APP_PATH\""
