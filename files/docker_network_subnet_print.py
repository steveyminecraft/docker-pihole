#!/usr/bin/env python3
"""Print Docker network IPv4 subnets from `docker network inspect` JSON on stdin."""
import json
import sys


def main() -> None:
    raw = sys.stdin.read()
    data = json.loads(raw) if raw.strip() else []
    for net in data:
        for cfg in (net.get("IPAM") or {}).get("Config") or []:
            sn = cfg.get("Subnet")
            if sn:
                print(sn)


if __name__ == "__main__":
    main()
