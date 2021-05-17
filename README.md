## Headless Test Runner

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

This repo contains the code and dockefile that allows any agent to create a headless web browser which 
logs into a specified instance, navigates to the client test runner page, and tearsdown the whole affair after.

