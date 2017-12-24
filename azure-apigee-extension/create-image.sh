#!/bin/bash
#This is the name used for all the artifacts created using this script
# ex: ./create-image.sh -g apigee -n apigeeedgetrail -u apigeetrail -p "iLoveapi\$" -k apigeese -s "password" -b 17x

azure_paramerer_file=azuredeploy.parameters.json

function usage ()
{
  echo 'Usage : Script -g <resource group> -n < deployment name> -u <VM User> -p <VM Password> -k <apigee FTP user> -s < apigee FTP Password> -b <Optional Branch Name>'
  echo "        -g              Resource group Name apigee"
  echo "        -n              Depployment Artifact name e.g apigeetrail"
  echo "        -u              VM Admin User e.g apigeetrail"
  echo "        -p              VM Admin Password "
  echo "        -k              Apigee FTP User Name e.g msft"
  echo "        -s              Apigee FTP Password "
  echo "        -b              GIT Branch e.g 16x"
  exit 1

}


while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -g)
    GROUP="$2"
    shift # past argument
    ;;
    -n)
    ARTIFACTS_NAME="$2"
    shift # past argument
    ;;
    -u)
    ADMIN_USER="$2"
    shift # past argument
    ;;
    -p)
    ADMIN_PASSWORD="$2"
    shift # past argument
    ;;
    -k)
    APIGEE_ACCESS_USERNAME="$2"
    shift # past argument
    ;;
    -s)
    APIGEE_ACCESS_PASSWORD="$2"
    shift # past argument
    ;;
    -b)
    GIT_BRANCH="$2"
    shift # past argument
    ;;
    -*)
    usage;
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

# extra validation for all required parameters
if [ "$GROUP" = "" ]
then
  usage
fi
if [ "$ARTIFACTS_NAME" = "" ]
then
  usage
fi
if [ "$ADMIN_USER" = "" ]
then
  usage
fi
if [ "$ADMIN_PASSWORD" = "" ]
then
  usage
fi
if [ "$APIGEE_ACCESS_USERNAME" = "" ]
then
  usage
fi
if [ "$APIGEE_ACCESS_PASSWORD" = "" ]
then
  usage
fi
if [ "$GIT_BRANCH" = "" ]
then
  GIT_BRANCH="master"
fi


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
	
	eval script_location=$(cat azuredeploy.json | jq '.parameters.scriptLocation.defaultValue' | sed -e 's/master/$GIT_BRANCH/g')
	echo $script_location
	cat ${azure_paramerer_file} | jq --arg SCRIPT_LOCATION ${script_location} '.parameters.scriptLocation.value=$SCRIPT_LOCATION' > ${azure_paramerer_file}.bk
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
	
	ssh_automate_deprovision;
}

ssh_automate_deprovision() {

echo "Deprovisioning user with sudo waagent -deprovision+user"
ip=$(azure network public-ip show -g $GROUP myPublicIP-${ARTIFACTS_NAME} | grep Fqdn | cut -d ':' -f 3 | tr -d ' ')

expect <<- DONE
        eval spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  ${ADMIN_USER}@${ip}
        #use correct prompt
        #set prompt ":|#|\\\$"
        set prompt ":|#|\\\$"

        expect "password"
        send "${ADMIN_PASSWORD}\r"
        expect "$ "
        send "sudo waagent -deprovision+user\r"
        expect "Do you want to proceed (y/n)"
        send "y\r"
        send "exit\r"
        expect eof
DONE

}


stop_vm_capture_image() {
	now=$(date +"%Y-%m-%d-%S")
	mv apigee-edge-trail-aio-profile.json apigee-edge-trail-aio-profile.$now.json

	echo $(date)
	azure config mode arm
	azure vm stop -g $GROUP -n ${ARTIFACTS_NAME}
	azure vm deallocate -g $GROUP -n ${ARTIFACTS_NAME}
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


function call_update_azure_parameters() {
        echo "This will update the parameters file with input parameters"

        read -r -p "Are you sure? [y/N] " response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                update_azure_parameters;
        elif [[ $response =~ ^([nN][oO]|[nN])$ ]]
        then
                exit;
        else
                call_update_azure_parameters;
        fi
}


function call_azure_remove() {
	echo "This will delete the group : " $GROUP

	read -r -p "Are you sure? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
   		azure_remove;
	elif [[ $response =~ ^([nN][oO]|[nN])$ ]]
	then
		exit;
	else
   		call_azure_remove; 
	fi
}

function call_azure_deploy() {

	echo "Starting the deployment.Please check if all base parameters are updated"

	read -r -p "Are you sure? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
   		azure_deploy;
	elif [[ $response =~ ^([nN][oO]|[nN])$ ]]
	then
		exit;
	else
   		call_azure_deploy;
	fi

}

function call_update_azure_vm() {

	echo "Check installation before we disable user provisioning and uninstall extenstion."
	echo "Deployment Finished."

	read -r -p "Are you sure? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
   		update_azure_vm;
	elif [[ $response =~ ^([nN][oO]|[nN])$ ]]
	then
		exit;
	else
   		call_update_azure_vm;
	fi

}

function call_stop_vm_capture_image() {

	echo "Now Capturing image"

	read -r -p "Are you sure? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
   		stop_vm_capture_image;
	elif [[ $response =~ ^([nN][oO]|[nN])$ ]]
        then
                exit;
	else
   		call_stop_vm_capture_image;
	fi
}


azure config mode arm
call_update_azure_parameters;
call_azure_remove;
call_azure_deploy;
call_update_azure_vm;
call_stop_vm_capture_image;

