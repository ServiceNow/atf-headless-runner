#!/usr/bin/python
# python3 start.py <instance url> <sn username> <browser name>
# <browser name> can be headlesschrome, headlessfirefox, or on Windows Edge

import sys
import docker
import uuid
import atexit
import os

def startDockerService(INSTANCE_URL, INSTANCE_USERNAME, BROWSER, AGENT_ID):
	print ('INSTANCE_URL: ' + INSTANCE_URL)
	print ('INSTANCE_USERNAME: ' + INSTANCE_USERNAME)
	print ('BROWSER: ' + BROWSER)
	print ('AGENT_ID: ' + AGENT_ID)

	SECRET_NAME = 'sn_password'
	IMAGE_NAME = 'atf_headless_runner'
	IMAGE_TAG = 'latest'
	SERVICE_NAME = str(uuid.uuid1()).replace('-', '')

	print ('SERVICE_NAME: ' + SERVICE_NAME)

	client = docker.from_env()

	env = [
		f'AGENT_ID={AGENT_ID}',
		f'INSTANCE_URL={INSTANCE_URL}',
		f'BROWSER={BROWSER}',
		f'SN_USERNAME={INSTANCE_USERNAME}',
		'LOGIN_PAGE=login.do',
		'TIMEOUT_MINS=1440',
		'RUNNER_URL=atf_test_runner.do?sysparm_nostack=true&sysparm_scheduled_tests_only=true&sysparm_headless=true',
		'PAGE_TITLE_TEXT=ServiceNow',
		'LOGIN_BUTTON_ID=sysverb_login',
		'USER_FIELD_ID=user_name',
		'PASSWORD_FIELD_ID=user_password',
		'HEADLESS_VALIDATION_PAGE=ui_page.do?sys_id=d21d8c0b772220103fe4b5b2681061a6',
		'VP_VALIDATION_ID=headless_vp_validation',
		'VP_HAS_ROLE_ID=headless_vp_has_role',
		'VP_SUCCESS_ID=headless_vp_success',
		'TEST_RUNNER_BANNER_ID=test_runner_banner',
		'HEARTBEAT_ENABLED=true',
		'HEARTBEAT_URI=/api/now/atf_agent/online',
	]

	# if os.name == 'nt':
	# 	env.append(f'SECRET_PATH=C:\\ProgramData\\docker\\secrets\\{SECRET_NAME}')
	# else:
	# 	env.append(f'SECRET_PATH=/run/secrets/{SECRET_NAME}')

	secretList = client.secrets.list()
	secrets = []
	for secret in secretList:
		secretRef = docker.types.SecretReference(secret.id, secret.name, uid='1000', gid='1000')
		secrets.append(secretRef)

	restart_policy = docker.types.RestartPolicy('any', 0, 1, 60000000000)

	service = client.services.create(IMAGE_NAME, env=env, secrets=secrets, restart_policy=restart_policy)

	def exit_handler():
	    service.remove()

	atexit.register(exit_handler)

	print ('Created Service : ' + service.id)
	return service

def printLogs(service):
	for line in service.logs(stdout=True, stderr=True, follow=True):
		print(line.strip())

if __name__ == "__main__":
	INSTANCE_URL = sys.argv[1]
	INSTANCE_USERNAME = sys.argv[2]
	BROWSER = sys.argv[3]

	AGENT_ID = ''
	if len(sys.argv) == 5:
		AGENT_ID = sys.argv[4]
	else:
		AGENT_ID = str(uuid.uuid1()).replace('-', '')

	service = startDockerService(INSTANCE_URL=INSTANCE_URL, INSTANCE_USERNAME=INSTANCE_USERNAME, BROWSER=BROWSER, AGENT_ID=AGENT_ID)
	printLogs(service)