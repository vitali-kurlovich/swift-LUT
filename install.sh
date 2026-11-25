#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-lut-convert}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

cd "$(dirname "$0")"

# Build the release executable.
swift build -c release --product "$APP_NAME"

# Ask SwiftPM for the actual binary directory.
BIN_DIR="$(swift build -c release --show-bin-path)"
BINARY="$BIN_DIR/$APP_NAME"

if [[ ! -f "$BINARY" ]]; then
  echo "Error: executable not found at: $BINARY" >&2
  exit 1
fi

# Create the destination directory if needed.
mkdir -p "$INSTALL_DIR"

# Install the executable.
install -m 0755 "$BINARY" "$INSTALL_DIR/$APP_NAME"

echo "Installed: $INSTALL_DIR/$APP_NAME"
