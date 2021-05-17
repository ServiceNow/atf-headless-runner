# THESE VARIBALES NEED TO BE SET
INSTANCE_URL=
INSTANCE_USERNAME=

# Can configure these if need be.
SECRET_NAME=sn_password
IMAGE_NAME=atf_headless_runner
IMAGE_TAG=latest


# Create a secret with that random name
echo "admin" | docker secret create $SECRET_NAME -

docker service create \
-e AGENT_ID=$(python -c 'import uuid; print str(uuid.uuid1()).replace("-", "")') \
-e INSTANCE_URL=$INSTANCE_URL \
-e BROWSER=headlesschrome \
-e SN_USERNAME=$INSTANCE_USERNAME \
-e TIMEOUT_MINS=1440 \
-e LOGIN_PAGE=login.do \
-e RUNNER_URL=atf_test_runner.do\?sysparm_nostack=true\&sysparm_scheduled_tests_only=true\&sysparm_headless=true \
-e BROWSER_OPTIONS=add_argument\(\'--no-sandbox\'\)\;add_argument\(\'--disable-gpu\'\) \
-e PAGE_TITLE_TEXT=ServiceNow \
-e LOGIN_BUTTON_ID=sysverb_login \
-e USER_FIELD_ID=user_name \
-e PASSWORD_FIELD_ID=user_password \
-e SECRET_PATH=/run/secrets/$SECRET_NAME \
-e HEADLESS_VALIDATION_PAGE=ui_page.do\?sys_id=d21d8c0b772220103fe4b5b2681061a6 \
-e VP_VALIDATION_ID=headless_vp_validation \
-e VP_HAS_ROLE_ID=headless_vp_has_role \
-e VP_SUCCESS_ID=headless_vp_success \
-e TEST_RUNNER_BANNER_ID=test_runner_banner \
-e HEARTBEAT_ENABLED=true \
-e HEARTBEAT_URI=/api/now/atf_agent/online \
--secret source=$SECRET_NAME,uid=1000,gid=1000,mode=0400 \
--restart-condition any \
--restart-delay 0s \
--restart-max-attempts 1 \
--restart-window 1m \
${IMAGE_NAME}:${IMAGE_TAG}

SERVICE_ID=$(docker service list -q)
echo $SERVICE_ID
docker service logs $SERVICE_ID -f
