#!/usr/bin/env python3

import urllib3
import json
from datetime import datetime

http = urllib3.PoolManager()
response = http.request("GET", "http://api.open-notify.org/iss-now.json")

data = json.loads(response.data.decode("utf-8"))

# print(json.dumps(data, indent=2))

timestamp = datetime.fromtimestamp(data['timestamp'])
# print(f"Time: {timestamp}")
# print(f"Latitude: {data['iss_position']['latitude']}")
# print(f"Longitude: {data['iss_position']['longitude']}")

with open("iss_position.txt", "a") as file:
    file.write(f"Time: {timestamp}\n")
    file.write(f"Latitude: {data['iss_position']['latitude']}\n")
    file.write(f"Longitude: {data['iss_position']['longitude']}\n")
    file.write("\n")