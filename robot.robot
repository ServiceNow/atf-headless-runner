*** Settings ***
Documentation    Script to startup a headless client test runner
Library    SeleniumLibrary
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Library    DateTime

*** Test Cases ***
Open browser
    Assign Variables
    Open Browser To Login Page
    Input Username
    Input Password
    Submit Credentials
    Go To Headless Validation Page
    Go To Test Runner Page
    Wait Until Keyword Succeeds    ${TIMEOUT_MINS} minute    1 minute     Is Agent Offline
    Log    The Client Test Runner is offline shutting down container    console=${True}

*** Keywords ***
Open Browser To Login Page
    ${LOGIN URL}=    Catenate   ${INSTANCE_URL}/${LOGIN_PAGE}
    Log    Login URL is ${LOGIN_URL}   console=${True}
    Open Browser    ${LOGIN URL}    ${BROWSER}  options=${BROWSER_OPTIONS}
    # Saw some weirdness with the login page so wait some extra time for the page to settle
    Sleep    2s

Go To Headless Validation Page
    # Test page should display basic message
    ${HEADLESS_VALIDATION_URL}=  Catenate   ${INSTANCE_URL}/${HEADLESS_VALIDATION_PAGE}
    Log    Going to entry: ${HEADLESS_VALIDATION_URL}    console=${True}
    Go To   ${HEADLESS_VALIDATION_URL}
    # Confirm it can browse to the page
    Page Should Contain Element    id:${VP_VALIDATION_ID}  Was unable to authenticate the ServiceNow user, please check username and password is correct. (Less likely) the validation page URL is incorrect: ${HEADLESS_VALIDATION_URL}
    # Validate it has the correct roles
    Page Should Contain Element    id:${VP_HAS_ROLE_ID}  The user does not have the right roles (atf_test_admin, atf_test_designer, or admin)
    # Add any custom validation here and on the validation page
    Page Should Contain Element    id:${VP_SUCCESS_ID}  The validation page did not fully load to validate the user: ${HEADLESS_VALIDATION_URL}

Go To Test Runner Page
    ${TEST RUNNER URL}=  Catenate   ${INSTANCE_URL}/${RUNNER_URL}&sys_atf_agent=${AGENT_ID}
    Log    Going to runner: ${TEST RUNNER URL}    console=${True}
    Go To   ${TEST RUNNER URL}
    Page Should Contain Element    id:${TEST_RUNNER_BANNER_ID}  The client test runner page could not load, Property sn_atf.schedule.enabled and sn_atf.runner.enabled must be true
    # Make sure the ATF Runner is online before we move on
    Log    Waiting for agent to come online    console=${True}
    Wait Until Keyword Fails    1 minute    10 seconds     Is Agent Offline
    Log    Agent is online    console=${True}

Input Username
    Log    Logging in user: ${USERNAME}    console=${True}
    Input Text    ${USER_FIELD_ID}    ${USERNAME}

Input Password
    ${PASSWORD}=    Get File    ${SECRET_PATH}
    Input Text    ${PASSWORD_FIELD_ID}    ${PASSWORD.strip()}

Submit Credentials
    ${CURRENT_USERNAME}=    Get Element Attribute    ${USER_FIELD_ID}    value
    ${CURRENT_PASSSWORD}=    Get Element Attribute    ${PASSWORD_FIELD_ID}    password
    ${PASSWORD}=    Get File    ${SECRET_PATH}

    # Do a sanity check to verify that the username/password fields got set properly and if not set them again
    Run Keyword Unless    "${CURRENT_USERNAME}" == "${USERNAME}"    Input Username
    Run Keyword Unless    "${CURRENT_PASSSWORD}" == "${PASSWORD.strip()}"    Input Password

    Click Button    ${LOGIN_BUTTON_ID}
    Log     Clicked Login Button    console=${True}

Is Agent Offline
    Run Keyword If    '${HEARTBEAT_ENABLED}'=='false'    fail

    ${PASSWORD}=    Get File    ${SECRET_PATH}

    # this is the combined string will be base64 encode
    ${userpass}=    Convert To Bytes    ${USERNAME}:${PASSWORD.strip()}
    ${userpass}=    Evaluate    base64.b64encode($userpass)    base64

    ${header}=    Create Dictionary   Authorization    Basic ${userpass}

    Create Session    heartbeat    ${INSTANCE_URL}   verify=true
    ${response}=    GET On Session    heartbeat    ${HEARTBEAT_URI}    params=id=${AGENT_ID}    headers=${header}

    ${DATETIME}=    Get Current Date    UTC    result_format=datetime   exclude_millis=true
    Log    ${DATETIME} | Heartbeat Response: ${response.json()}    console=${True}


    Dictionary Should Contain Key    ${response.json()}    result
    Dictionary Should Contain Item    ${response.json()['result']}    online    false

Assign Variables
    Environment Variable Should Be Set  AGENT_ID  The agent ID should be auto-generated from the instance
    Environment Variable Should Be Set  BROWSER  There was no browser type identified in the request
    Environment Variable Should Be Set  INSTANCE_URL  The instance URL was not configured (add or set property: glide.servlet.uri)
    Environment Variable Should Be Set  SN_USERNAME  There was no user specified (add or set property: sn_atf.headless.username)
    Environment Variable Should Be Set  TIMEOUT_MINS  There was no timeout specified in the request (add or set property: sn_atf.headless.timeout_mins)
    Environment Variable Should Be Set  SECRET_PATH  There was no secret file path specified (add or set property: sn_atf.headless.secret_path)
    Environment Variable Should Be Set  LOGIN_PAGE  There was no login page specified in the request (add or set property: sn_atf.headless.login_page)
    Environment Variable Should Be Set  RUNNER_URL  There was no atf client test runner page specified in the request (add or set property: sn_atf.headless.runner_url)
    Environment Variable Should Be Set  BROWSER_OPTIONS  There were no browser options specified in the request (add or set property: sn_atf.headless.browser_options)
    Environment Variable Should Be Set  LOGIN_BUTTON_ID  There was no login buttun element idspecified in the request (add or set property: sn_atf.headless.login_button_id)
    Environment Variable Should Be Set  USER_FIELD_ID  There was no username element specified in the request (add or set property: sn_atf.headless.user_field_id)
    Environment Variable Should Be Set  PASSWORD_FIELD_ID  There was no password element specified in the request (add or set property: sn_atf.headless.password_field_id)
    Environment Variable Should Be Set  HEADLESS_VALIDATION_PAGE  There was no validation page specified in the request (add or set property: sn_atf.headless.validation_page)
    Environment Variable Should Be Set  VP_VALIDATION_ID  There was no validation element id specified in the request (add or set property: sn_atf.headless.validation_id)
    Environment Variable Should Be Set  VP_HAS_ROLE_ID  There was no role element id specified in the request (add or set property: sn_atf.headless.vp_has_role_id)
    Environment Variable Should Be Set  VP_SUCCESS_ID  There was no success element id specified in the request (add or set property: sn_atf.headless.vp_success_id)
    Environment Variable Should Be Set  TEST_RUNNER_BANNER_ID   There was no banner element id page specified in the request (add or set property: sn_atf.headless.runner_banner_id)

    ${AGENT_ID}=    Get Environment Variable    AGENT_ID
    ${BROWSER}=    Get Environment Variable    BROWSER
    ${INSTANCE_URL}=    Get Environment Variable    INSTANCE_URL
    ${USERNAME}=    Get Environment Variable    SN_USERNAME
    ${TIMEOUT_MINS}=    Get Environment Variable    TIMEOUT_MINS
    ${SECRET_PATH}=    Get Environment Variable    SECRET_PATH
    ${LOGIN_PAGE}=    Get Environment Variable    LOGIN_PAGE
    ${RUNNER_URL}=    Get Environment Variable    RUNNER_URL
    ${BROWSER_OPTIONS}=    Get Environment Variable    BROWSER_OPTIONS
    ${LOGIN_BUTTON_ID}=    Get Environment Variable    LOGIN_BUTTON_ID
    ${USER_FIELD_ID}=    Get Environment Variable    USER_FIELD_ID
    ${PASSWORD_FIELD_ID}=    Get Environment Variable    PASSWORD_FIELD_ID
    ${HEADLESS_VALIDATION_PAGE}=    Get Environment Variable    HEADLESS_VALIDATION_PAGE
    ${VP_VALIDATION_ID}=    Get Environment Variable    VP_VALIDATION_ID
    ${VP_HAS_ROLE_ID}=    Get Environment Variable    VP_HAS_ROLE_ID
    ${VP_SUCCESS_ID}=    Get Environment Variable    VP_SUCCESS_ID
    ${TEST_RUNNER_BANNER_ID}=    Get Environment Variable    TEST_RUNNER_BANNER_ID
    ${HEARTBEAT_ENABLED}=   Get Environment Variable    HEARTBEAT_ENABLED
    ${HEARTBEAT_URI}=    Get Environment Variable    HEARTBEAT_URI

    Set Global Variable    ${AGENT_ID}
    Set Global Variable    ${BROWSER}
    Set Global Variable    ${INSTANCE_URL}
    Set Global Variable    ${USERNAME}
    Set Global Variable    ${SECRET_PATH}
    Set Global Variable    ${TIMEOUT_MINS}
    Set Global Variable    ${LOGIN_PAGE}
    Set Global Variable    ${RUNNER_URL}
    Set Global Variable    ${BROWSER_OPTIONS}
    Set Global Variable    ${LOGIN_BUTTON_ID}
    Set Global Variable    ${USER_FIELD_ID}
    Set Global Variable    ${PASSWORD_FIELD_ID}
    Set Global Variable    ${HEADLESS_VALIDATION_PAGE}
    Set Global Variable    ${VP_VALIDATION_ID}
    Set Global Variable    ${VP_HAS_ROLE_ID}
    Set Global Variable    ${VP_SUCCESS_ID}
    Set Global Variable    ${TEST_RUNNER_BANNER_ID}
    Set Global Variable    ${HEARTBEAT_ENABLED}
    Set Global Variable    ${HEARTBEAT_URI}
    Verify Variables

Verify Variables
    Variable Should Exist   ${AGENT_ID}
    Log    AGENT_ID is ${AGENT_ID}  console=${True}
    Variable Should Exist   ${BROWSER}
    Log    BROWSER is ${BROWSER}    console=${True}
    Variable Should Exist   ${INSTANCE_URL}
    Log    INSTANCE_URL is ${INSTANCE_URL}  console=${True}
    Variable Should Exist   ${USERNAME}
    Log    USERNAME is ${USERNAME}  console=${True}
    Variable Should Exist   ${SECRET_PATH}
    Log    Secret Path: ${SECRET_PATH}  console=${True}
    Variable Should Exist   ${TIMEOUT_MINS}
    Log    TIMEOUT is ${TIMEOUT_MINS} minutes  console=${True}
    Variable Should Exist   ${LOGIN_PAGE}
    Log    LOGIN_PAGE is ${LOGIN_PAGE}  console=${True}
    Variable Should Exist   ${RUNNER_URL}
    Log    RUNNER_URL is ${RUNNER_URL}  console=${True}
    Variable Should Exist   ${BROWSER_OPTIONS}
    Log    BROWSER_OPTIONS is ${BROWSER_OPTIONS}  console=${True}
    Variable Should Exist   ${LOGIN_BUTTON_ID}
    Log    LOGIN_BUTTON_ID is ${LOGIN_BUTTON_ID}  console=${True}
    Variable Should Exist   ${USER_FIELD_ID}
    Log    USER_FIELD_ID is ${USER_FIELD_ID}  console=${True}
    Variable Should Exist   ${PASSWORD_FIELD_ID}
    Log    PASSWORD_FIELD_ID is ${PASSWORD_FIELD_ID}  console=${True}
    Variable Should Exist   ${HEADLESS_VALIDATION_PAGE}
    Log    HEADLESS_VALIDATION_PAGE is ${HEADLESS_VALIDATION_PAGE}  console=${True}
    Variable Should Exist   ${VP_VALIDATION_ID}
    Log    VP_VALIDATION_ID is ${VP_VALIDATION_ID}  console=${True}
    Variable Should Exist   ${VP_HAS_ROLE_ID}
    Log    VP_HAS_ROLE_ID is ${VP_HAS_ROLE_ID}  console=${True}
    Variable Should Exist   ${VP_SUCCESS_ID}
    Log    VP_SUCCESS_ID is ${VP_SUCCESS_ID}  console=${True}
    Variable Should Exist   ${TEST_RUNNER_BANNER_ID}
    Log    TEST_RUNNER_BANNER_ID is ${TEST_RUNNER_BANNER_ID}  console=${True}
    Variable Should Exist   ${HEARTBEAT_ENABLED}
    Log    HEARTBEAT_ENABLED is ${HEARTBEAT_ENABLED}  console=${True}
    Variable Should Exist   ${HEARTBEAT_URI}
    Log    HEARTBEAT_URI is ${HEARTBEAT_URI}  console=${True}

Wait Until Keyword Fails
    [Arguments]    ${timeout}    ${retry}    ${keyword}    @{args}
    Wait Until Keyword Succeeds    ${timeout}    ${retry}
    ...    Run Keyword And Expect Error    *
    ...    ${keyword}    @{args}
