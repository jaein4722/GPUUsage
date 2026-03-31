#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-0.2.4}"
SHORT_SHA="$(git -C "$ROOT_DIR" rev-parse --short HEAD | tr '[:upper:]' '[:lower:]')"
APP_NAME="GPUUsage-${VERSION}-test-${SHORT_SHA}"
APP_PATH="$ROOT_DIR/dist/${APP_NAME}.app"
TEST_BUNDLE_ID="com.leejaein.GPUUsage.test.${SHORT_SHA}"

APP_NAME="$APP_NAME" \
BUNDLE_ID="$TEST_BUNDLE_ID" \
BUILD_CONFIGURATION="${BUILD_CONFIGURATION:-debug}" \
SKIP_DMG=1 \
"$ROOT_DIR/scripts/package_app.sh"

echo "Test app bundle: $APP_PATH"
echo "Open it with: open \"$APP_PATH\""
