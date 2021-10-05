# Headless Browser for Automated Test Framework

The Automated Testing Framework (ATF) enables customers to test their applications and instances, giving them the confidence 
when developing inside of the ServiceNow Platform that their changes both have the desired behavior, and don’t break other 
existing features. In the Orlando release of ServiceNow customers are able to automate the testing and deployment of their 
applications via the Continuous Integration and Continuous Delivery (CICD) API. This ability to automate common developer tasks 
is crucial to the advancement of ServiceNow as a full fledged PaaS offering. With that goal in mind, the following proposals 
put forth a plan for customers to automate the creation of browsers to process ATF User Interface (UI) tests. 
Right now, when a customer wants to test UI functionality, they must manually open a browser to the “Client Test Runner” 
which will process the UI tests in their local browser. However, when running UI tests via CICD, if a user does not have 
a Client Test Runner manually opened for testing, the tests will error out. This leads to users not being able to effectively 
automate their development processes, without putting forth unreasonable resources such as a dedicated computer + screen to process their UI tests.

This repo contains the code and dockerfile that allows any agent to create a headless web browser which logs into a specified instance, navigates to the client test runner page, and tears down the whole affair after.

Make sure you have Docker installed. 
Installation instructions for Linux/MacOS can be found [here](https://docs.docker.com/get-docker/), and instructions for Windows Server can be found [here](https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=Windows-Server#install-docker)

## "Production" Usage

1. Pull the image with the correct tag: `docker pull ghcr.io/servicenow/atf-headless-runner:<lin | win>-<version>`
2. Follow instructions in `docs/docker_host_setup.md` to configure your server to be able to connect to your ServiceNow instance

## Development

### Running locally
1. [Install Docker](https://docs.docker.com/desktop/mac/install/)
2. Clone this repo `https://github.com/ServiceNow/atf-headless-runner.git`
3. cd into the repo
4. Build Image from dockerfile: `$ docker build -t atf_headless_browser .`
5. `$ docker swarm init` this starts docker swarm which gives us access to the docker secrets module
6. `$ echo "ServiceNow password" | docker secret create sn_password -` adding the instance password as a docker secret
7. `$ python3 start.py http://<ServiceNow Instance URL> <ServiceNow Username> (headlesschrome|headlessfirefox)` starting a container from our image and having it connect to an already existing instance

### Verify Success in instance (Rome and later)
1. Start the docker container using the steps above
2. Wait for the "Agent is online" message in the logs
3. Go to the `sys_atf_agent` table
4. Should see a record for the agent with correct OS type and correct browser type with status "online"

### Instance integration
1. Run `docker run -d -v /var/run/docker.sock:/var/run/docker.sock --name socat -p 127.0.0.1:2375:2375 bobrik/socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock` to expose the docker API locally ono port 2375
2. Verify the docker API is exposed by running `curl http://localhost:2375/images/json` and if you get a response then its successful
3. In instance Create sys_connection record:
- type: HTTP
- Name: Anything (Docker ATF)
- Connection Alias: the docker spoke
- Connection URL: http://localhost:2375

3. In ATF Properties page, set the following properties:
- enabled = true
- user account login = admin
- secret id = run `docker secret list` and copy the ID of the sn_password secret
- docker image = atf_headless_browser:latest

4. Make sure no other Scheduled Client Test Runners are connected to the instance
5. Create a new ATF Schedule Record, 
- Runs On: "On Demand" 
- Test Suite: "Child A"
- Browser Name: Any (will default the headless to run in Chrome, can select Chrome or firefox)
- OS Name: Any

6. Click "Run Now"
7. See the tests run in a headless environment, an ad hoc docker container will be created for each test run

## CI Setup

The Continuous integration for this repo is setup in github actions defined in the .github/workflows directory. Upon every commit to a PR to master or commit on master the action will build the docker image an start a container that connects to `https://atfheadlessrunner.service-now.com`. Then it will use the Table API to verify that a `sys_atf_agent` record will all the correct values is present. 

## Releasing 

1. On the repo home page click "Releases"
<img width="457" alt="Screen Shot 2021-10-05 at 3 54 59 PM" src="https://user-images.githubusercontent.com/13264552/136101451-9425ac83-d0fa-4b39-b053-dd9cb306b8b5.png">

2. Click "Draft a New Release"
3. In the release title put the new version number
4. Click publish release

Upon pubishing the release a github action will automatically be created which will build BOTH the windows and linux docker images from the repo, and will upload both of them to [Github Containeer Registry](https://github.com/ServiceNow/atf-headless-runner/pkgs/container/atf-headless-runner). The tags of the images will be: `lin-version` (for linux), and `win-version` (for windows).

# Notices

## Support Model

ServiceNow built this integration with the intent to help customers get started faster in adopting Automated Testing and CI/CD APIs for DevOps workflows, but __will not be providing formal support__. This integration is therefore considered "use at your own risk", and will rely on the open-source community to help drive fixes and feature enhancements via Issues. Occasionally, ServiceNow may choose to contribute to the open-source project to help address the highest priority Issues, and will do our best to keep the integrations updated with the latest API changes shipped with family releases. This is a good opportunity for our customers and community developers to step up and help drive iteration and improvement on these open-source integrations for everyone's benefit. 

## Governance Model

Initially, ServiceNow product management and engineering representatives will own governance of these integrations to ensure consistency with roadmap direction. In the longer term, we hope that contributors from customers and our community developers will help to guide prioritization and maintenance of these integrations. At that point, this governance model can be updated to reflect a broader pool of contributors and maintainers. 
