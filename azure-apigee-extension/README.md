# Azure Apigee Installation
***This extension is still in POC stage, and is not certified by Apigee or Microsoft***

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fapigee%2Fmicrosoft%2F16x%2Fazure-apigee-extension%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Apigee Instance in Azure
The template presently supports `aio` profile of the opdk, where all the components are installed on one box.

The following configurations are needed by the template:
Once the VM is successfully provisioned, you can access Apigee Management UI http://<FQDN name or public IP>:9000/


### The Parameters are as follows 

```
  "ftpServer": "FTP Server to Download edge binaries & licenses."
  "ftpUserName": "FTP user"
  "ftpPassword": "FTP Password"
  "ftpLicenseFile": "License file path in FTP server . Default -/License/license.txt"
  "ftpEdgeBinaryPath": "/apigee_enterprise_OPDK/API_Services/apigee-edge-4.15.07.03.zip"
  "vmSize": "Select VM size from List. Standard A3 is default"
  "newStorageAccountName": "Unique name to define Storage account"
  "vmDnsName": "Unique name of VM"
  "adminUserName": "VM Admin User"
  "adminPassword": "VM Admin Password"
  "apigeeSuperAdmin": "OPDK SuperAdmin user Defaults to opdk@apigee.com"
  "apigeeSuperAdminPassword": "The password for OPDK installation"
  "apigeeOrgName": "The Organization Defaults to demo"
  "apigeeOrgEnv": "The Environment for Org .Defaults to test"
  "apigeeEnvVhost": "Default Vhost name . Default to default."
  "apigeeEnvVhostPort": "The VHost port . Default to 9001."
  "imagePublisher": "The Publisher of CentOS .Default to OpenLogic."
  "imageOffer": "The image . Default to CentOS."
  "imageSKU": "The version . Default to 6.6."
  "edgeVersion": "The version of edge which is currently 4.15.07"
```
