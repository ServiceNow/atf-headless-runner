URL=$1
USER_PASSWORD=$2
BROWSER=$3
EXPECTED_BROWSER_NAME=$4
EXPECTED_OS=$5

AGENT_ID=$(python -c 'import uuid; print (str(uuid.uuid1()).replace("-", ""))')
./docker-start.sh $URL admin $BROWSER $AGENT_ID &
sleep 1m

echo "Agent ID: $AGENT_ID"

RESULT=$(curl "$URL/api/now/table/sys_atf_agent/$AGENT_ID" \
	--request GET \
	--header "Accept:application/json" \
	--user 'admin':"$USER_PASSWORD")

echo $RESULT

OS=$(echo $RESULT | python -c 'import json,sys;obj=json.load(sys.stdin);print (obj["result"]["os_name"]);')
BROWSER=$(echo $RESULT | python -c 'import json,sys;obj=json.load(sys.stdin);print (obj["result"]["browser_name"]);')
STATUS=$(echo $RESULT | python -c 'import json,sys;obj=json.load(sys.stdin);print (obj["result"]["status"]);')
HEADLESS=$(echo $RESULT | python -c 'import json,sys;obj=json.load(sys.stdin);print (obj["result"]["headless"]);')

if [ "$BROWSER" != "$EXPECTED_BROWSER_NAME" ] 
then
	echo "Browser should have been $EXPECTED_BROWSER_NAME but was $BROWSER"
	exit 1
fi

if [ "$OS" != "$EXPECTED_OS" ] 
then
	echo "OS should have been $EXPECTED_OS but was $OS"
	exit 1
fi

if [ "$STATUS" != "online" ] 
then
	echo "Status should have been online but was $STATUS"
	exit 1
fi

if [ "$HEADLESS" != "true" ] 
then
	echo "Browser should have been true but was $HEADLESS"
	exit 1
fi