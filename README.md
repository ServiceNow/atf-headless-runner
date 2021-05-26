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

## Linux/Mac OS

Make sure you have Docker installed. Installation instructions for Linux can be found [here](https://docs.docker.com/get-docker/)

### Building the Image
`$ docker build -t atf_headless_browser .`

### Running locally in Docker
1. `$ docker swarm init`
2. `$ echo "Your ServiceNow password" | docker secret create sn_password -`
3. Make sure to add your corrected values to the ENV variables in `docker-start.sh` script
4. `$ ./docker-start.sh`

### Verify Success in instance
1. Start the docker container using the steps above
2. Wait for the "Agent is online" message in the logs
3. Go to the `sys_atf_agent` table
4. Should see a record for the agent with OS type of Linux and with the configured browser with status "online"

### Stopping and removing all services

When the container and service startup successfully via `docker-start.sh` the serivce/container will be automatically 
stopped, and removed. If the container doesn't startup successfully, you might need to manually remove the service by 
running `docker service list` to get the ID of the service, and run `docker service rm <service id>` to remove it.

## Windows Server

Make sure you have Docker installed. Installation instructions for Windows Server can be found [here](https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=Windows-Server#install-docker)

### Building the Image
Since Windows Docker images need to be based on the same version of windows as the host machine you will most likely need 
to change the Dockerfile to match the base. 
1. In an administrator command line run `ver` you are looking for the windows version including build number (ex: 10.0.17763.1879)
2. Change the tag on the first line of `Dockerfile.windows` to match the windows version of your host
2. `$ docker build -f Dockerfile.windows -t atf_headless_browser .`

### Running locally in Docker

Make sure that your computer is able to connect to your SerivceNow instance, and that
you have a user created with the "admin" or "atf_test_designer role"

1. `$ docker swarm init`
2. `$ echo Your_ServiceNow_password | docker secret create sn_password -`
3. Change values in docker-start.sh to match your ServiceNow instance. Additionally change the SECRET_PATH docker env variable to be: `C:\ProgramData\Docker\secrets\%SECRET_NAME%`
4. `$ ./docker-start.sh`

### Verify Success in instance
1. Start the docker container using the steps above
2. Wait for the "Agent is online" message in the logs
3. Go to the `sys_atf_agent` table
4. Should see a record for the agent with OS type of Linux and with the configured browser with status "online"

### Stopping and removing all services

When the container and service startup successfully via `docker-start.sh` the serivce/container will be automatically 
stopped, and removed. If the container doesn't startup successfully, you might need to manually remove the service by 
running `docker service list` to get the ID of the service, and run `docker service rm <service id>` to remove it.

# Notices

## Support Model

ServiceNow built this integration with the intent to help customers get started faster in adopting Automated Testing and CI/CD APIs for DevOps workflows, but __will not be providing formal support__. This integration is therefore considered "use at your own risk", and will rely on the open-source community to help drive fixes and feature enhancements via Issues. Occasionally, ServiceNow may choose to contribute to the open-source project to help address the highest priority Issues, and will do our best to keep the integrations updated with the latest API changes shipped with family releases. This is a good opportunity for our customers and community developers to step up and help drive iteration and improvement on these open-source integrations for everyone's benefit. 

## Governance Model

Initially, ServiceNow product management and engineering representatives will own governance of these integrations to ensure consistency with roadmap direction. In the longer term, we hope that contributors from customers and our community developers will help to guide prioritization and maintenance of these integrations. At that point, this governance model can be updated to reflect a broader pool of contributors and maintainers. 