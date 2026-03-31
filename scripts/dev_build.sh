#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

swift build "$@"
"$ROOT_DIR/scripts/build_test_app.sh"
