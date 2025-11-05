#!/usr/bin/env bash
set -euo pipefail

PRINT_USAGE=false
SYSTEM_INSTALL=false

for arg in "$@"; do
	case "$arg" in
		--system)
			SYSTEM_INSTALL=true
			;;
		--help|-h)
			PRINT_USAGE=true
			;;
		*)
			;;
	esac
done

if [ "$PRINT_USAGE" = true ]; then
	cat <<EOF
Usage: install.sh [--system]

Installs BATMAN scripts to the user's local data directory and symlinks a convenience command into ~/bin.
Pass --system to install into /usr/local/bin (requires sudo).
EOF
	exit 0
fi

echo "📦 Installing BATMAN..."

# Create the user-local data dir
mkdir -p "$HOME/.local/share/battery-tools"
cp -v scripts/* "$HOME/.local/share/battery-tools/"

# Ensure user bin exists and create a symlink
mkdir -p "$HOME/bin"
ln -sf "$HOME/.local/share/battery-tools/battery-manager.sh" "$HOME/bin/battery-manager" || true

if [ "$SYSTEM_INSTALL" = true ]; then
	echo "Installing to system: /usr/local/bin (requires sudo)"
	sudo cp -v "$HOME/.local/share/battery-tools/battery-manager.sh" /usr/local/bin/battery-manager || true
	sudo cp -v "$HOME/.local/share/battery-tools/battery-conservation-on" /usr/local/bin/ || true
	sudo cp -v "$HOME/.local/share/battery-tools/battery-conservation-off" /usr/local/bin/ || true
	sudo cp -v "$HOME/.local/share/battery-tools/battery-status" /usr/local/bin/ || true
fi

echo "✅ Installed. Add $HOME/bin to your PATH if it's not already present. Run: battery-manager or battery-status"
