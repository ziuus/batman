echo "Run: batman --help or ./batman help"
#!/usr/bin/env bash
# install.sh - simple, idempotent installer for batman
# Usage: ./install.sh [--prefix PATH] [--no-sudo]

set -euo pipefail

PREFIX="/usr/local"
NO_SUDO=0

usage() {
  cat <<EOF
Usage: $0 [--prefix PATH] [--no-sudo]

  --prefix PATH   Install into PATH (defaults to /usr/local)
  --no-sudo       Do not use sudo; useful for installing into a user prefix
  -h, --help      Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix)
      PREFIX="$2"; shift 2;;
    --prefix=*)
      PREFIX="${1#--prefix=}"; shift 1;;
    --no-sudo)
      NO_SUDO=1; shift 1;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 2;;
  esac
done

BIN_DIR="$PREFIX/bin"
mkdir -p "$BIN_DIR"

SRC_BIN="$(pwd)/batman"
if [ ! -f "$SRC_BIN" ]; then
  echo "Error: batman executable not found in repository root. Build or copy it here first." >&2
  exit 1
fi

TARGET="$BIN_DIR/batman"

# if target exists and is identical, skip
if [ -f "$TARGET" ]; then
  if cmp -s "$SRC_BIN" "$TARGET"; then
    echo "batman already installed at $TARGET and is identical. Nothing to do."
    exit 0
  else
    BACKUP="$TARGET.$(date +%Y%m%d%H%M%S).bak"
    echo "Backing up existing $TARGET to $BACKUP"
    if [ "$NO_SUDO" -eq 1 ]; then
      mv "$TARGET" "$BACKUP"
    else
      sudo mv "$TARGET" "$BACKUP"
    fi
  fi
fi

# copy in place
if [ "$NO_SUDO" -eq 1 ]; then
  cp "$SRC_BIN" "$TARGET"
  chmod 0755 "$TARGET"
else
  sudo install -m 0755 "$SRC_BIN" "$TARGET"
fi

echo "Installed batman -> $TARGET"
echo "Run: batman --help or ./batman help"
