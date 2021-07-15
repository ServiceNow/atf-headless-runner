#!/usr/bin/python
# python3 test.py http://192.168.1.10:8080 admin headlesschrome Chrome Linux

from start import startDockerService, printLogs
from multiprocessing import Pool
import time
import requests
import json
import unittest
import sys
import uuid
import time

URL=sys.argv[1]
USER_PASSWORD=sys.argv[2]
BROWSER=sys.argv[3]
EXPECTED_BROWSER_NAME=sys.argv[4]
EXPECTED_OS=sys.argv[5]

AGENT_ID = str(uuid.uuid1()).replace('-', '')

service = startDockerService(INSTANCE_URL=URL, INSTANCE_USERNAME='admin', BROWSER=BROWSER, AGENT_ID=AGENT_ID)

t_end = time.time() + 60

for line in service.logs(stdout=True, stderr=True, follow=True):
	print(line.strip())
	if b'{\'online\': \'true\'}' in line:
		break
	if time.time() >= t_end:
		break


url = f'{URL}/api/now/table/sys_atf_agent/{AGENT_ID}'
headers = {"Content-Type":"application/json","Accept":"application/json"}
response = requests.get(url, auth=('admin', USER_PASSWORD), headers=headers )

if response.status_code != 200: 
    print('Status:', response.status_code, 'Headers:', response.headers, 'Error Response:',response.json())
    exit('Response from Instance was not 200')

data = response.json()
print(data)

BROWSER = data["result"]["browser_name"]
assert EXPECTED_BROWSER_NAME == BROWSER, f'OS should have been {EXPECTED_BROWSER_NAME} but was {BROWSER}'

OS = data["result"]["os_name"]
assert "Linux" == EXPECTED_OS, f'OS should have been {EXPECTED_OS} but was {OS}'

STATUS = data["result"]["status"]
assert "online" == STATUS, f'OS should have been online but was {STATUS}'

HEADLESS = data["result"]["headless"]
assert "true" == HEADLESS, f'Headless should have been True but was False'
