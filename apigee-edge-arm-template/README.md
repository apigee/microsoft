
# apigee-edge-arm-template
This project allows you to install edge in Azure using Azure resource manager template. 

## Prerequisite

### azure
- Create an account with azure portal. You may get free quota to run aio. To run multi node, you need additional CPU quota and have to request azure support team to upgrade quota. 

## Apigee Private Cloud
Please go through http://docs.apigee.com/private-cloud/content/version-41705 to know more about Apigee Edge Private Cloud.

## Apigee Deployment on GCP

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
- Create a ssh key pair 
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

- Understanding Parameters.

    
    

## Troubleshootig

It uses ansible based scripts for multi node installation and there can be cases where the edge doesnt get installed even after 30 minutes. It may require additional diaganosis on what may have gone wrong in installation.
o what may have gone wrong.


## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.

# Azure Apigee Installation

***This extension is still in POC stage, and is not certified by Apigee or Microsoft***

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fapigee%2Fmicrosoft%2Fmaster%2Fapigee-edge-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Apigee Instance in Azure

The template presently supports `aio` profile of the opdk, where all the components are installed on one box.

The template takes the following configurations: 


Once the VM is successfully provisioned, you can access Apigee Management UI http://<FQDN name or public IP>:9000/

