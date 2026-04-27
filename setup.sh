#!/usr/bin/env bash
# Bootstrap helper for mikoshi-example.
# Run this from inside the mikoshi-example directory after `nixos-generate-config --root /mnt`
# and after cloning the repo into /mnt/etc/nixos/.
#
# What it does:
#   1. Copies ../hardware-configuration.nix into the current directory
#   2. Extracts system.stateVersion from ../configuration.nix
#   3. Replaces the `systemStateVersion = throw "..."` line in flake.nix with the real value
#   4. Runs `git add .`
#

set -euo pipefail


if [[ ! -f flake.nix ]]; then
    echo "Error: flake.nix not found in $(pwd)." >&2
    echo "Run this script from inside the mikoshi-example directory." >&2
    exit 1
fi

if [[ ! -f ../hardware-configuration.nix ]]; then
    echo "Error: ../hardware-configuration.nix not found." >&2
    echo "Did you run 'nixos-generate-config --root /mnt' first?" >&2
    exit 1
fi

if [[ ! -f ../configuration.nix ]]; then
    echo "Error: ../configuration.nix not found." >&2
    echo "Cannot extract stateVersion without it." >&2
    exit 1
fi


cp ../hardware-configuration.nix .
echo "Copied hardware-configuration.nix"

state_version="$(
    grep -E '^\s*system\.stateVersion\s*=\s*"[^"]+"' ../configuration.nix \
        | head -n1 \
        | sed -E 's/.*"([^"]+)".*/\1/'
)"

if [[ -z "${state_version}" ]]; then
    echo "Error: could not extract system.stateVersion from ../configuration.nix" >&2
    exit 1
fi

echo "Detected stateVersion: ${state_version}"


if grep -q 'systemStateVersion = throw' flake.nix; then
    # Use a backup file then move it, so we don't half-write on failure.
    sed -E "s|systemStateVersion = throw \"[^\"]*\";|systemStateVersion = \"${state_version}\";|" \
        flake.nix > flake.nix.tmp
    mv flake.nix.tmp flake.nix
    echo "Replaced systemStateVersion in flake.nix"
else
    echo "systemStateVersion already set in flake.nix — skipping patch"
fi


if [[ -d .git ]]; then
    git add .
    echo "Staged changes with git add ."
else
    echo "No .git directory — skipping git add"
fi

echo
echo "Done. You still need to edit flake.nix to set 'username' and 'hostname'."
