
# apigee-edge-arm-template
This project allows you to install edge in Azure using Azure resource manager template. 

## Prerequisite

### azure
- Create an account with azure portal. You may get free quota to run aio. To run multi node, you need additional CPU quota and have to request azure support team to upgrade quota. 

## Apigee Private Cloud
Please go through http://docs.apigee.com/private-cloud/content/version-41709 to know more about Apigee Edge Private Cloud.

## Apigee Deployment on Azure

 - At this point of time, supported topologies are 1,5 and 9. 
 - Additionally it also create Developer portal in a separate node for all supported toplogies. So for example if you choose to deploy 5 node topology, it will deploy developer portal on 6th node.
 
 - Supported Deployment Topologies

Edge Topology- 1 node
![Edge Topology- 1 node](/images/1node.png)

Edge Topology- 5 node
![Edge Topology- 5 node](/images/5node.png)

Edge Topology- 9 node
![Edge Topology- 9 node](/images/9node.png)


## Getting Started
- Create a ssh key pair with the user apigeetrial. Replace -C parameter if your machine's admin user is different than apigeetrial.
    ```
    ssh-keygen -t rsa -b 4096 -C "apigeetrial" -N "" -f apigeetrial.key
    ```
    This generates a key pair file apigee.key and apigee.key.pub
    - so the public key file should like  
          ```
            sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMQYOx.....2OA0jecyUx+3+Okp2dzhw== apigeetrial
          ```
- Deploy to Azure using link below
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fapigee%2Fmicrosoft%2Fmaster%2Fapigee-edge-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

   - This template allows you to create a Apigee Instance in Azure.The template presently supports `aio` profile of the opdk, where all the components are installed on one box.
Once the VM is successfully provisioned, you can access Apigee Management UI http://<FQDN name or public IP>:9000/

- Understanding Parameters
![Understanding Parameters](/images/azuredeploy.png)


    | properties        | Description                                    |
    | ----------------- |:-----------------------------------------------| 
    | Resource Group    | Always recommened to have apigee edge installed in a new Resource Group            |
    | Location          | azure location. Choose from the dropdown.    | 
    | Location          | Type in the same location you had choosen from the dropdown                                   |
    | Tshirt Size              | Choose XSmall for 1 node, Medium for 5 node and Large for 5 node installation                           |
    | Apigee Deployment Name           | Name of the deployment      |
    | Admin User Name| Admin user name of machine. If you change the default value, you must create the key pair for that user as described above.                        |
    | Authentication Type    | Choose from possible case of password or sshPublicKey. For Medium and Large it always has to be sshKey                    |
    | password     | If you have choosen authentication type as password, please provide the machine password. Please give 6 - 72 characters with 1 capital, 1 numeric and 1 special characters.                          |
    | Ssh Key          | The ssh Public Key. If you have choosen authenticationType as sshPublicKey, please copy and paste the contents from apigeetrial.key.pub here.                                |
    | Apigee Admin Email         | Apigee Edge system user email address               |
    | Apigee Admin Password          | Apigee Edge system user password                                     |
    | Ssh Private Key      | Private key of the generated pair. Copy and paste the contents of apigeetrial.key here.                                |
    | License File Text          | Copy and Paste the contents of Apigee Edge license file.                        |
    | Org      | Apigee Edge Organization              |
    | Smtp-host           | SMTP Host                                 |
    | smtp-port          | SMTP port (25 for non ssl, 465 for ssl)                                 |
    | smtp-ssl           | y or n                   |
    | smtp-username        | SMTP user name|
    | smtp-password       | SMTP password|
    | smtp-mailfrom       | SMTP mail from|
    
- An example of parameters reference would be 


    | properties        | Description                                    |
    | ----------------- |:-----------------------------------------------| 
    | Resource Group    | driveapigee            |
    | Location          | Central US    | 
    | Location          | Central US                                   |
    | Tshirt Size              | Medium                         |
    | Apigee Deployment Name           | driveapigee      |
    | Admin User Name| apigeetrial                        |
    | Authentication Type    | sshPublicKey                  |
    | password     | iLoveapi$123                          |
    | Ssh Key          | ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDob0vmpjxLKoN9zx7Zk0VbPYl8ayu7DJ3PDG4SMpdkQmrU9p+kQ== apigeetrial|
    | Apigee Admin Email         | apigeetrial@apigee.com               |
    | Apigee Admin Password          | Secret123                                     |
    | Ssh Private Key      |-----BEGIN RSA PRIVATE KEY-----
MIIJKQIBAAKCAgEA6G7OHtJBZEoLS1+7rEQCw6fZ4dZ/bzPKTwhEWaK3aFsHts9D
OYDCLUfcN/y8lX8Mi81b5ijFISr+JqV2xXyzvDxYPzgjLKwtKXRDv1nq7Oku7xQW
-----END RSA PRIVATE KEY-----|
    | License File Text          |                         |
    | Org      | apigeetrial              |
    | Smtp-host           | smtp.gmail.com                                 |
    | smtp-port          | 465                                |
    | smtp-ssl           | y                   |
    | smtp-username        | myname@apigee.com|
    | smtp-password       | MyGmailAppGenPassword|
    | smtp-mailfrom       | noreply@apigee.com|


## Troubleshootig

It uses ansible based scripts for multi node installation and there can be cases where the edge doesnt get installed even after 30 minutes. It may require additional diaganosis on what may have gone wrong in installation.
o what may have gone wrong.


## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.

