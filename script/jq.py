#!/usr/bin/env python3

import json
import sys

data = json.load(sys.stdin)
for ip in data["addresses"]:
    print(ip)
