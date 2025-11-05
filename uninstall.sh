#!/usr/bin/env bash
set -euo pipefail

echo "🗑️ Uninstalling BATMAN..."
rm -rf "$HOME/.local/share/battery-tools"
rm -f "$HOME/bin/battery-manager" "$HOME/bin/batman"

# Remove system-wide installs if present (use sudo if available)
if sudo -n true 2>/dev/null; then
	sudo rm -f /usr/local/bin/battery-manager /usr/local/bin/battery-status /usr/local/bin/battery-conservation-on /usr/local/bin/battery-conservation-off /usr/local/bin/batman || true
else
	# best-effort without sudo
	rm -f /usr/local/bin/battery-manager /usr/local/bin/battery-status /usr/local/bin/battery-conservation-on /usr/local/bin/battery-conservation-off /usr/local/bin/batman || true
fi

echo "✅ Uninstalled."
