#!/usr/bin/env bash
# Lightweight wrapper that delegates to the more featureful interactive manager
# This file simply forwards common subcommands to the full manager.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER="${SCRIPT_DIR}/battery-manager-full.sh"

if [ -x "$MANAGER" ]; then
    exec "$MANAGER" "$@"
else
    # If the full manager isn't present, provide minimal built-ins
    case "${1:-status}" in
        status|-s)
            exec "${SCRIPT_DIR}/battery-status"
            ;;
        on|enable)
            exec "${SCRIPT_DIR}/battery-conservation-on"
            ;;
        off|disable)
            exec "${SCRIPT_DIR}/battery-conservation-off"
            ;;
        *)
            echo "battery-manager: basic wrapper"
            echo "Usage: $0 [status|on|off]"
            exit 2
            ;;
    esac
fi
