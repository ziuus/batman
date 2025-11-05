# Battery Manager Scripts (BATMAN)

This document documents the battery manager scripts included in this repository and how to install/use them.

Included scripts (in `scripts/`):

- `battery-manager-full.sh` — full interactive manager (menu, toggle, enable/disable, status)
- `battery-manager.sh` — lightweight wrapper that calls the full manager when available
- `battery-conservation-on` — enable conservation mode (writes `1` to sysfs)
- `battery-conservation-off` — disable conservation mode (writes `0` to sysfs)
- `battery-status` — simple status output (capacity, state, conservation mode)

Notes

- The Lenovo-specific conservation sysfs path used by these scripts is:

  `/sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode`

  If your hardware exposes a different path, update the scripts accordingly.

Install manually

```bash
# Make scripts executable
chmod +x scripts/*

# Copy wrappers to a system-wide bin directory (requires sudo)
sudo cp scripts/battery-manager.sh scripts/battery-conservation-on scripts/battery-conservation-off scripts/battery-status /usr/local/bin/

# (Optional) copy the full interactive manager too
sudo cp scripts/battery-manager-full.sh /usr/local/bin/battery-manager-full
```

Usage examples

- Show status (user-readable):

```bash
battery-status
```

- Enable conservation mode (requires sudo):

```bash
sudo battery-conservation-on
```

- Disable conservation mode (requires sudo):

```bash
sudo battery-conservation-off
```

Notes & transparency

I previously referenced a `battery-manager` command in a GitHub issue discussion but had not included the source in the repository; that is now corrected — the scripts above are the implementation used to control Lenovo's conservation mode via the kernel sysfs interface. If maintainers prefer a different approach (for example, using TLP or upstream integration), I'm happy to adapt.
