#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="argonone-fan.service"
PY_PATH="/usr/local/bin/argonone-fan.py"
CONF_PATH="/etc/argonone-fan.conf"
UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}"

# Resolve repo-relative paths no matter where this script is run from
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo bash install-argonone-fan.sh"
    exit 1
  fi
}

install_deps() {
  echo "[1/5] Installing dependencies..."
  if command -v apt >/dev/null 2>&1; then
    apt update -y
    apt install -y python3 python3-rpi.gpio libraspberrypi-bin
  else
    echo "apt not found. Please ensure Python3, RPi.GPIO, and vcgencmd are installed."
  fi
}

write_conf() {
  if [ -f "$CONF_PATH" ]; then
    echo "[2/5] Preserving existing $CONF_PATH"
    return
  fi
  echo "[2/5] Installing default config to $CONF_PATH"
  install -D -m 0644 "${SCRIPT_DIR}/config/argonone-fan.conf" "$CONF_PATH"
}

write_script() {
  echo "[3/5] Installing control script to $PY_PATH"
  install -D -m 0755 "${SCRIPT_DIR}/scripts/argonone-fan.py" "$PY_PATH"
}

write_service() {
  echo "[4/5] Installing systemd unit $UNIT_PATH"
  install -D -m 0644 "${SCRIPT_DIR}/systemd/argonone-fan.service" "$UNIT_PATH"
}

enable_service() {
  echo "[5/5] Enabling and starting service..."
  systemctl daemon-reload
  systemctl enable "$SERVICE_NAME"
  systemctl restart "$SERVICE_NAME"

  echo
  systemctl --no-pager --full status "$SERVICE_NAME" || true
  echo
  echo "✔ Installed."
  echo "Config:  $CONF_PATH"
  echo "Script:  $PY_PATH"
  echo "Service: $SERVICE_NAME"
  echo
  echo "Edit thresholds in $CONF_PATH then:"
  echo "  sudo systemctl restart $SERVICE_NAME"
}

require_root
install_deps
write_conf
write_script
write_service
enable_service
