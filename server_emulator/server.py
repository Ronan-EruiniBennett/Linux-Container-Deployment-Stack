import os
import random
import time

import requests

TARGET_URL = os.environ["TARGET_URL"]
HEARTBEAT_INTERVAL_SECONDS = 5

SERVER_IDS = ["web-01", "web-02", "db-01", "cache-01"]
STATUSES = ["ok", "ok", "ok", "ok", "degraded", "down"]


def send_heartbeat():
    payload = {
        "server_id": random.choice(SERVER_IDS),
        "server_status": random.choice(STATUSES),
    }

    try:
        response = requests.post(TARGET_URL, json=payload, timeout=5)
        print(f"Sent {payload} -> {response.status_code}", flush=True)
    except requests.RequestException as e:
        print(f"Failed to send heartbeat: {e}", flush=True)


if __name__ == "__main__":
    while True:
        send_heartbeat()
        time.sleep(HEARTBEAT_INTERVAL_SECONDS)
