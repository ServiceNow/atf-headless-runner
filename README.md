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

## Local Development

### Building the Image
`$ docker build -t atf_headless_browser .`

### Running locally
1. `$ docker swarm init`
2. `$ echo "ServiceNow password" | docker secret create sn_password -`
3. `$ python3 start.py http://<ServiceNow Instance URL> <ServiceNow Username> (headlesschrome|headlessfirefox)`

### Verify Success in instance (Rome and later)
1. Start the docker container using the steps above
2. Wait for the "Agent is online" message in the logs
3. Go to the `sys_atf_agent` table
4. Should see a record for the agent with correct OS type and correct browser type with status "online"

# Notices

## Support Model

ServiceNow built this integration with the intent to help customers get started faster in adopting Automated Testing and CI/CD APIs for DevOps workflows, but __will not be providing formal support__. This integration is therefore considered "use at your own risk", and will rely on the open-source community to help drive fixes and feature enhancements via Issues. Occasionally, ServiceNow may choose to contribute to the open-source project to help address the highest priority Issues, and will do our best to keep the integrations updated with the latest API changes shipped with family releases. This is a good opportunity for our customers and community developers to step up and help drive iteration and improvement on these open-source integrations for everyone's benefit. 

## Governance Model

Initially, ServiceNow product management and engineering representatives will own governance of these integrations to ensure consistency with roadmap direction. In the longer term, we hope that contributors from customers and our community developers will help to guide prioritization and maintenance of these integrations. At that point, this governance model can be updated to reflect a broader pool of contributors and maintainers. 