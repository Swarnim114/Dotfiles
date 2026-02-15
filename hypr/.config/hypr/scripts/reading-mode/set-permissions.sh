#!/usr/bin/env bash
# Set executable permissions for all reading mode scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$SCRIPT_DIR/reading-mode.sh"
chmod +x "$SCRIPT_DIR/test-integration.sh"

echo "✓ Permissions set for reading mode scripts"
