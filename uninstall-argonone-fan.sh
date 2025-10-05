#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="argonone-fan.service"
PY_PATH="/usr/local/bin/argonone-fan.py"
CONF_PATH="/etc/argonone-fan.conf"
UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo bash uninstall-argonone-fan.sh"
  exit 1
fi

systemctl stop "$SERVICE_NAME" || true
systemctl disable "$SERVICE_NAME" || true
rm -f "$UNIT_PATH"
systemctl daemon-reload

rm -f "$PY_PATH"
# Keep the config by default; uncomment next line to remove it too:
# rm -f "$CONF_PATH"

echo "✔ Uninstalled service. You may remove $CONF_PATH if you don't need it."
