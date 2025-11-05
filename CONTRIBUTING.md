Thank you for your interest in contributing to BATMAN.

Small guidelines:

- Keep changes small and focused. One feature or fix per PR.
- Add tests where appropriate (scripts should check for missing sysfs interfaces).
- Use clear commit messages and describe the rationale in the PR.
- If your change affects install/uninstall behavior, update `install.sh` and `uninstall.sh` accordingly.

Reporting issues:

- Open an issue with reproducible steps and the output of `battery-status` when possible.

Code style:

- Scripts use Bash. Please prefer POSIX-compatible constructs where reasonable and use `#!/usr/bin/env bash` as the shebang.
