# Azure Apigee Installation
***This extension is still in POC stage, and is not certified by Apigee or Microsoft***

This section creates a base Apigee image for installation.

./create-image.sh -g <resource group> -n < deployment name> -u <VM User> -p <VM Password> -k <apigee FTP user> -s < apigee FTP Password> -b <Optional Branch Name>'
  
for ex:
./create-image.sh -g apigee -n apigeeedgetrail -u apigeetrail -p "iLoveapi\$" -k apigeese -s <password> -b 17x

Once this is installed, you get a file apigee-edge-trail-aio-profile.json
