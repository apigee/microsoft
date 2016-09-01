#!/bin/bash
#This is the name used for all the artifacts created using this script
# ex: ./create-image.sh apigee apigeeedgetrail apigeetrail "iLoveapi\$" msft "bs%msftpassword\$l1"

if [ "$#" -ne 6 ]; then
  echo "Usage: ./create-image resource artifact edge-user edge-passwordi access-user access-password"  
  echo "e.g : ./create-image apigee apigeeedgetrail apigeetrail Secret123 msft xyz3rty" 
  exit 1
fi

echo "starting to create image : " $(date)
GROUP=$1
ARTIFACTS_NAME=$2
ADMIN_USER=$3
ADMIN_PASSWORD=$4
APIGEE_ACCESS_USERNAME=$5
APIGEE_ACCESS_PASSWORD=$6

azure_paramerer_file=azuredeploybase.parameters.json

azure config mode arm


update_azure_parameters() {
	cat ${azure_paramerer_file} | jq --arg ARTIFACTS_NAME $ARTIFACTS_NAME '.parameters.newStorageAccountName.value=$ARTIFACTS_NAME' > ${azure_paramerer_file}.bk
	cat ${azure_paramerer_file}.bk > ${azure_paramerer_file}
	cat ${azure_paramerer_file} | jq --arg ARTIFACTS_NAME $ARTIFACTS_NAME '.parameters.vmDnsName.value=$ARTIFACTS_NAME' > ${azure_paramerer_file}.bk
	cat ${azure_paramerer_file}.bk > ${azure_paramerer_file}
	cat ${azure_paramerer_file} | jq --arg ADMIN_USER $ADMIN_USER '.parameters.adminUserName.value=$ADMIN_USER' > ${azure_paramerer_file}.bk
	cat ${azure_paramerer_file}.bk > ${azure_paramerer_file}
	cat ${azure_paramerer_file} | jq --arg ADMIN_PASSWORD $ADMIN_PASSWORD '.parameters.adminPassword.value=$ADMIN_PASSWORD' > ${azure_paramerer_file}.bk
	cat ${azure_paramerer_file}.bk > ${azure_paramerer_file}
	cat ${azure_paramerer_file} | jq --arg APIGEE_ACCESS_USERNAME $APIGEE_ACCESS_USERNAME '.parameters.ftpUserName.value=$APIGEE_ACCESS_USERNAME' > ${azure_paramerer_file}.bk
	cat ${azure_paramerer_file}.bk > ${azure_paramerer_file}
	cat ${azure_paramerer_file} | jq --arg APIGEE_ACCESS_PASSWORD $APIGEE_ACCESS_PASSWORD '.parameters.ftpPassword.value=$APIGEE_ACCESS_PASSWORD' > ${azure_paramerer_file}.bk
	cat ${azure_paramerer_file}.bk > ${azure_paramerer_file}
	rm -fr ${azure_paramerer_file}.bk
	echo "Updated parameters file from inputs"
}

azure_remove() {
	azure vm stop -g $GROUP ${ARTIFACTS_NAME}
	azure vm delete -g $GROUP ${ARTIFACTS_NAME} -q
	azure network nic delete -g $GROUP myVMNic-${ARTIFACTS_NAME} -q
	azure network public-ip delete -g $GROUP myPublicIP-${ARTIFACTS_NAME} -q
	azure network vnet delete -g $GROUP myVNet-${ARTIFACTS_NAME} -q
	azure storage account delete -g $GROUP ${ARTIFACTS_NAME} -q
	azure group delete $GROUP -q
}


azure_deploy() {
	azure group create $GROUP "West US"
        azure group deployment create -g $GROUP -f azuredeploy.json -e ${azure_paramerer_file} -v -q
}

update_azure_vm() {

	echo "Uninstalling Custom extensions"
	azure vm extension set -u ${GROUP} ${ARTIFACTS_NAME} newuserscript Microsoft.OSTCExtensions 1.2 -q

	echo "Deprovisioning user with sudo waagent -deprovision+user"
	ip=$(azure network public-ip show -g $GROUP myPublicIP-${ARTIFACTS_NAME} | grep FQDN | cut -d ':' -f 3 | tr -d ' ')
	ssh ${ADMIN_USER}@$ip  sudo waagent -deprovision+user
}

stop_vm_capture_image() {
	now=$(date +"%Y-%m-%d-%S")
	mv apigee-edge-trail-aio-profile.json apigee-edge-trail-aio-profile.$now.json

	echo $(date)
	azure config mode arm
	azure vm stop -g $GROUP -n ${ARTIFACTS_NAME}
	azure vm generalize -g $GROUP -n ${ARTIFACTS_NAME}
	azure vm capture -g $GROUP -n ${ARTIFACTS_NAME} -p apigeeedge -t apigee-edge-trail-aio-profile.json

	echo 'image capture done. Deleting the artifacts created for capturing the image'
	echo $(date)
	azure vm stop -g $GROUP ${ARTIFACTS_NAME}
	azure vm delete -g $GROUP ${ARTIFACTS_NAME} -q
	azure network nic delete -g $GROUP myVMNic-${ARTIFACTS_NAME} -q
	azure network public-ip delete -g $GROUP myPublicIP-${ARTIFACTS_NAME} -q
	azure network vnet delete -g $GROUP myVNet-${ARTIFACTS_NAME} -q
	echo "The captured image is : "
	echo $(cat apigee-edge-trail-aio-profile.json | jq '.resources[].properties.storageProfile.osDisk.image.uri')

	echo $(date)
}



update_azure_parameters;

echo "This will delete the group : " $GROUP

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
   azure_remove;
else
   exit; 
fi


echo "Starting the deployment.Please check if all base parameters are updated"

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
   azure_deploy;
else
   exit;
fi

echo "Check installation before we disable user provisioning and uninstall extenstion."
echo "Deployment Finished."

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
   update_azure_vm;
else
   exit;
fi

echo "Now Capturing image"

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
   stop_vm_capture_image;
else
   exit;
fi

exit;
