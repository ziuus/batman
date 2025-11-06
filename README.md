# BATMAN — Battery Manager CLI

BATMAN is a minimal, auditable command-line utility to read battery state and toggle Lenovo-style "conservation" charging mode via the kernel sysfs interface. The tool is intentionally small, portable, and scriptable so it can be reviewed and packaged easily.

## Motivation
Modern laptops may provide a "conservation" mode that limits charging to prolong battery lifespan. BATMAN provides a tiny, transparent interface to:
- Query battery capacity and charging status
- Enable/Disable/Toggle conservation mode
- Be safely included in scripts, packages, and automated workflows

## Features
- Single-file CLI (`batman`) with no runtime dependencies beyond bash
- Commands: status, enable/on, disable/off, toggle, interactive, help
- Environment-variable overrides for sysfs paths (for testing or alternate hardware)
- CI builds release artifacts (.tar.gz and .deb) and publishes checksums

## Supported hardware
BATMAN acts on kernel-exposed sysfs files. It's tested on systems that expose:
- a battery under `/sys/class/power_supply/BAT0/` (capacity, status)
- a vendor conservation control sysfs node (path configurable)

If your hardware exposes equivalent sysfs nodes, BATMAN can be used by overriding the default paths via environment variables.

## Quick usage

Show status:
```bash
batman status
```

Enable conservation mode (may require sudo):
```bash
sudo batman enable
# or
sudo batman on
```

Disable conservation mode:
```bash
sudo batman disable
# or
sudo batman off
```

Toggle mode:
```bash
batman toggle
```

Interactive menu:
```bash
batman interactive
```

Help:
```bash
batman help
```

## Installation

Option A — Install from release tarball (recommended)
```bash
# download the release tarball, verify checksum, extract, then install
curl -L -o batman.tar.gz "https://github.com/<owner>/batman/releases/download/vX.Y.Z/batman-vX.Y.Z.tar.gz"
sha256sum batman.tar.gz      # verify with checksums published in Release
tar -xzf batman.tar.gz
sudo install -m 0755 batman /usr/local/bin/batman
```

Option B — Use included installer (developer)
```bash
# idempotent, supports --prefix and --no-sudo
./install.sh --prefix="$HOME/.local"
```

Option C — Build and create a .deb (CI produces this automatically on releases)
```bash
# build a .deb locally (example)
# see docs/packaging or CI workflow for the exact steps used in releases
```

Notes
- Prefer verifying SHA256 checksums before installing binary artifacts.
- The repo includes an `install.sh` convenience script for local installs.

## Environment overrides (useful for testing)
To run BATMAN against alternative or mocked sysfs paths, set one or more environment variables:
- CONSERVATION_MODE — path to the conservation_mode node
- BATTERY_CAPACITY — path to battery capacity (default `/sys/class/power_supply/BAT0/capacity`)
- BATTERY_STATUS — path to battery status (default `/sys/class/power_supply/BAT0/status`)

Example:
```bash
CONSERVATION_MODE=/tmp/mock/conservation_mode \
BATTERY_CAPACITY=/tmp/mock/capacity \
BATTERY_STATUS=/tmp/mock/status \
./batman status
```

## How it works (brief)
- Reads battery capacity and status from the configured `BATTERY_CAPACITY` and `BATTERY_STATUS` sysfs files.
- Reads/writes the `CONSERVATION_MODE` sysfs file to enable/disable conservation (writes `1` to enable, `0` to disable).
- If direct write is not permitted, the script falls back to using `sudo tee` when appropriate (user will be prompted for password).

## Development & testing
- Script language: bash (shebang: `#!/usr/bin/env bash`)
- Linting: run `shellcheck batman`
- Smoke tests in CI use mocked sysfs files so CI runs on runners without real battery hardware
- To run the included smoke test locally, run the test script in `tests/` (if present) or set env overrides and run `./batman status`

## CI / Packaging (what the repo provides)
- GitHub Actions run shellcheck, a mocked smoke test, and package artifacts:
  - `batman-<tag>.tar.gz`
  - `batman-<tag>_<ver>.deb`
  - `checksums.sha256`
- Releases attach artifacts automatically on tag push (see workflow file).

## Troubleshooting
- "Path not found" errors: ensure your battery and vendor sysfs paths exist or use environment variable overrides.
- Permission denied on writes: use `sudo batman enable` or adjust udev rules if you want non-root access.
- Unexpected output: run `batman help` and verify the default sysfs variables used.

## Security & safety notes
- BATMAN writes to kernel sysfs and can affect charging behavior. Use with care.
- Do not run arbitrary install scripts from the internet without verifying release checksums.
- Consider reviewing the `batman` script before installation — it is intentionally small to simplify auditing.

## Contributing
- Follow the guidelines in `CONTRIBUTING.md`.
- Keep changes small and test with the included smoke tests.
- Use `shellcheck` and preserve the simple, auditable design.

## License
- MIT — see `LICENSE` for the full text.
