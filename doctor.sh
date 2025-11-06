#!/bin/bash
set -euo pipefail

echo "🔍 Running BATMAN doctor checks..."

# Prefer checking for installed commands in PATH
if command -v batman >/dev/null 2>&1 || command -v battery-manager >/dev/null 2>&1 || command -v battery-status >/dev/null 2>&1; then
    echo "✅ BATMAN CLI tools found in PATH"
    exit 0
fi

# Fallback: check user-local install
if [ -f "$HOME/.local/share/battery-tools/battery-manager.sh" ] || [ -f "$HOME/.local/share/battery-tools/battery-status" ]; then
    echo "✅ BATMAN scripts found in $HOME/.local/share/battery-tools"
    exit 0
fi

echo "❌ BATMAN not installed (no battery-manager or battery-status found)"
echo "Install with: ./install.sh or see docs/BATTERY_MANAGER.md"
exit 2
