# Argon One Fan Controller (Custom)

A lightweight, configurable fan controller for Argon One cases on Raspberry Pi.

## What you get
- **`scripts/argonone-fan.py`** – Python daemon controlling the fan with PWM
- **`config/argonone-fan.conf`** – Editable thresholds and settings
- **`systemd/argonone-fan.service`** – Service file (if you want to install manually)
- **`install-argonone-fan.sh`** – One-shot installer (recommended)
- **`uninstall-argonone-fan.sh`** – Clean removal

Tested on Raspberry Pi OS (Bookworm) with Pi 4/5.

---

## Quick install (local files)
Copy this folder onto your Pi (or download the ZIP), then run:
```bash
cd argonone-fan-repo
sudo bash install-argonone-fan.sh
```

Check status:
```bash
sudo systemctl status argonone-fan.service
```

Edit thresholds:
```bash
sudo nano /etc/argonone-fan.conf
# Then apply
sudo systemctl restart argonone-fan.service
```

## Uninstall
```bash
cd argonone-fan-repo
sudo bash uninstall-argonone-fan.sh
```

---

## Config format (`/etc/argonone-fan.conf`)
Threshold rules are `tempC:duty` pairs (percent). Highest matching rule applies.

```
55:25
65:50
75:100
poll_interval=10
fan_pin=18
pwm_freq=50
# stop_below=50  # optional: force fan off below this temp
```

## Notes
- Default pin for Argon One is **GPIO18 (BCM)**.
- Requires `python3-rpi.gpio` and `libraspberrypi-bin` (installer will install via `apt`).

