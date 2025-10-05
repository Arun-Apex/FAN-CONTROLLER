#!/usr/bin/env bash
set -euo pipefail

# FAN-CONTROLLER bootstrap
# Downloads this repo (branch/tag you specify), extracts it, and runs the installer.
#
# Usage:
#   sudo bash bootstrap.sh                # uses default ref=main, installer=install-argonone-fan.sh
#   sudo bash bootstrap.sh v1.0.0         # install from tag v1.0.0
#   sudo bash bootstrap.sh main path/to/custom-installer.sh

REPO_OWNER="Arun-Apex"
REPO_NAME="FAN-CONTROLLER"

REF="${1:-main}"                                       # branch or tag
INSTALLER_REL_PATH="${2:-install-argonone-fan.sh}"     # path inside repo

die() { echo "Error: $*" >&2; exit 1; }

# --- Preflight ---
[ "$(id -u)" -eq 0 ] || die "Please run as root (use: sudo)."
command -v curl >/dev/null 2>&1 || die "'curl' is required."
command -v tar  >/dev/null 2>&1 || die "'tar' is required."

TMPDIR="$(mktemp -d -t fanctl-XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

ARCHIVE_URL="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${REF}"
TARBALL="${TMPDIR}/${REPO_NAME}.tar.gz"

echo "[1/4] Downloading ${REPO_OWNER}/${REPO_NAME}@${REF} ..."
curl -fL "$ARCHIVE_URL" -o "$TARBALL"

echo "[2/4] Extracting files ..."
tar -xzf "$TARBALL" -C "$TMPDIR"
SRC_DIR="$(find "$TMPDIR" -maxdepth 1 -type d -name "${REPO_NAME}-${REF}" -print -quit)"
[ -d "$SRC_DIR" ] || die "Extracted folder not found (expected ${REPO_NAME}-${REF})."

INSTALLER="${SRC_DIR}/${INSTALLER_REL_PATH}"
[ -f "$INSTALLER" ] || die "Installer not found at: ${INSTALLER_REL_PATH}"

echo "[3/4] Making installer executable ..."
chmod +x "$INSTALLER"

echo "[4/4] Running installer ..."
bash "$INSTALLER"

echo "✔ Done."
echo "Check service status with: sudo systemctl status argonone-fan.service"
