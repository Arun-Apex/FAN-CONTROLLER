#!/usr/bin/env python3
import os, signal, sys, time
import RPi.GPIO as GPIO

CONF_PATH = "/etc/argonone-fan.conf"

def read_cpu_temp_c():
    # Prefer vcgencmd; fallback to thermal_zone0
    try:
        out = os.popen("vcgencmd measure_temp").read().strip()
        if out.startswith("temp="):
            return float(out.split('=')[1].split("'" )[0])
    except Exception:
        pass
    try:
        with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
            return int(f.read().strip()) / 1000.0
    except Exception:
        return 0.0

def parse_conf(path):
    rules = []  # list of (tempC, duty)
    conf = {"poll_interval":10, "fan_pin":18, "pwm_freq":50, "stop_below":None}
    if not os.path.exists(path):
        return rules, conf
    with open(path, "r") as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if ":" in line:
                try:
                    t, d = line.split(":", 1)
                    rules.append((float(t), float(d)))
                except Exception:
                    pass
            elif "=" in line:
                k, v = [x.strip() for x in line.split("=", 1)]
                if k == "poll_interval":
                    conf["poll_interval"] = max(1, int(float(v)))
                elif k == "fan_pin":
                    conf["fan_pin"] = int(v)
                elif k == "pwm_freq":
                    conf["pwm_freq"] = max(1, int(float(v)))
                elif k == "stop_below":
                    try:
                        conf["stop_below"] = float(v)
                    except:
                        conf["stop_below"] = None
    rules.sort(key=lambda x: x[0])
    return rules, conf

_running = True
def handle_sigterm(sig, frame):
    global _running
    _running = False

def main():
    signal.signal(signal.SIGTERM, handle_sigterm)
    signal.signal(signal.SIGINT, handle_sigterm)

    rules, conf = parse_conf(CONF_PATH)
    fan_pin = conf["fan_pin"]
    pwm_hz = conf["pwm_freq"]
    poll = conf["poll_interval"]
    stop_below = conf["stop_below"]

    GPIO.setmode(GPIO.BCM)
    GPIO.setup(fan_pin, GPIO.OUT)
    pwm = GPIO.PWM(fan_pin, pwm_hz)
    pwm.start(0)
    last_dc = -1.0

    try:
        while _running:
            temp = read_cpu_temp_c()

            duty = 0.0
            for (thr, dc) in rules:
                if temp >= thr:
                    duty = dc
            if stop_below is not None and temp < stop_below:
                duty = 0.0

            duty = max(0.0, min(100.0, duty))
            if abs(duty - last_dc) > 0.1:
                pwm.ChangeDutyCycle(duty)
                last_dc = duty

            time.sleep(poll)
    finally:
        try:
            pwm.ChangeDutyCycle(0)
            pwm.stop()
        except Exception:
            pass
        GPIO.cleanup()

if __name__ == "__main__":
    sys.exit(main())
