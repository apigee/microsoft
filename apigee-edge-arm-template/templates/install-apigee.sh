#sudo ./install-apigee.sh apigeetrial apigeetrial@apigee.com secret apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1:10.0.0.2:10.0.0.3:10.0.0.4:10.0.0.5 $LICENSE $SSH

mkdir -p /tmp/apigee/log
ARMLOGPATH=/tmp/apigee/log/armextension.log
echo 'executing the install script' >>${ARMLOGPATH}


install_apigee() {

	#Get ansible scripts in /tmp/apigee/ansible directory
	mkdir -p /tmp/apigee/ansible-scripts
	mkdir -p /tmp/apigee/ansible-scripts/inventory
	mkdir -p /tmp/apigee/ansible-scripts/playbook
	mkdir -p /tmp/apigee/ansible-scripts/config

	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_1node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_1node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_5node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_5node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_9node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_9node

	curl -o /tmp/apigee/ansible-scripts/config/aio-config.txt  $FILE_BASEPATH/ansible-scripts/config/aio-config.txt
	curl -o /tmp/apigee/ansible-scripts/config/dp-config.txt  $FILE_BASEPATH/ansible-scripts/config/dp-config.txt
	curl -o /tmp/apigee/ansible-scripts/config/grafana.txt  $FILE_BASEPATH/ansible-scripts/config/grafana.txt
	curl -o /tmp/apigee/ansible-scripts/config/config5.txt  $FILE_BASEPATH/ansible-scripts/config/config5.txt
	curl -o /tmp/apigee/ansible-scripts/config/config9.txt  $FILE_BASEPATH/ansible-scripts/config/config9.txt
	curl -o /tmp/apigee/ansible-scripts/config/setup-org-prod.txt  $FILE_BASEPATH/ansible-scripts/config/setup-org-prod.txt
	curl -o /tmp/apigee/ansible-scripts/config/setup-org-test.txt  $FILE_BASEPATH/ansible-scripts/config/setup-org-test.txt

	curl -o /tmp/apigee/ansible-scripts/playbook/ansible.cfg  $FILE_BASEPATH/ansible-scripts/playbook/ansible.cfg
	curl -o /tmp/apigee/ansible-scripts/playbook/dp-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/dp-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/ds-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ds-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/rmp-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/rmp-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/r-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/r-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/mp-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/mp-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/ps-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ps-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/qs-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/qs-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/ms-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ms-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/orgsetup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/orgsetup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-prerequisite-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-prerequisite-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-presetup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-presetup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-components-setup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-components-setup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-setup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-setup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-dashboard-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-dashboard-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-telegraf-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-telegraf-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-uninstall-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-uninstall-playbook.yaml

}

setup_variables() {

	echo 'Initializing variables' >>${ARMLOGPATH}

    REPO_USER=$1
    REPO_PASSWORD=$2
    REPO_HOST="software.apigee.com"
    REPO_PROTOCOL="https"
    REPO_STAGE="release"
    EDGE_VERSION=$3
    #FILE_BASEPATH="https://raw.githubusercontent.com/apigee/microsoft/master/azure-apigee-extension/"
    FILE_BASEPATH=$4

	USER_NAME=$5
	APIGEE_ADMIN_EMAIL=$6
	APW=$7
	VHOST_ALIAS=$8
	VHOST_NAME='default'
	VHOST_PORT_PROD='9001'
	VHOST_PORT_TEST='9002'
	
	DEPLOYMENT_TOPOLOGY=$9
	LB_IP_ALIAS=${10}
	HOST_NAMES=${11}
	LICENSE_TEXT=${12}
	SSH_KEY=${13}
	ORG_NAME=${14}
	SMTPHOST=${15}
	SMTPPORT=${16}
	SMTPSSL=${17}
	SMTPMAILFROM=${18}
	SMTPUSER=${19}
	SMTPPASSWORD=${20}
	SKIP_SMTP="n"
	login_user=$USER_NAME
	
	MSIP=$(hostname -i)

	echo "args: $*" >>${ARMLOGPATH}
	echo 'Inititalized variables, '$REPO_USER, $REPO_PASSWORD, $REPO_HOST, $FILE_BASEPATH, $VHOST_ALIAS, $EDGE_VERSION, $DEPLOYMENT_TOPOLOGY, $LB_IP_ALIAS, "Hosts: " $HOST_NAMES  >>${ARMLOGPATH}
}



setup_ssh_key_and_license() {

	echo 'Setting License file to /tmp/apigee/ansible-scripts/config/license.txt' >>${ARMLOGPATH}
	LICENSE_TEXT=`echo ${LICENSE_TEXT} | base64 --decode`

	SSH_KEY=`echo ${SSH_KEY} | base64 --decode`


	echo "Copy license file to /tmp/apigee/ansible-scripts/config location" >> ${ARMLOGPATH}
	cd /tmp/apigee/ansible-scripts/config
	rm -rf license.txt

	#Replace space with new lines before writing to file
	echo $LICENSE_TEXT | tr " " "\n"> license.txt

	echo 'License file Set' >>${ARMLOGPATH}

	echo 'Setting ssh key' >>${ARMLOGPATH}

	if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then

		cd /tmp/apigee
		ssh-keygen -t rsa -N "" -C ${login_user} -f my.key
		mkdir -p ~/.ssh
		mv -f my.key ~/.ssh/id_rsa
	        chmod 600 ~/.ssh/id_rsa
		mkdir -p /home/${login_user}/.ssh
		cat my.key.pub >>  /home/${login_user}/.ssh/authorized_keys
		echo "Copy the ssh key to id_rsa in home directory of root" >>${ARMLOGPATH}
	        key_path=~/.ssh/id_rsa

	        echo 'ssh key set to '$key_path >>${ARMLOGPATH}
	else 

		cd /tmp/apigee
		yum install dos2unix -y
		echo $SSH_KEY | tr " " "\n" > ssh_key.pem
		dos2unix ssh_key.pem

		#This is all because the spaces in the bellow lines are also converted to new lines!
		echo '-----BEGIN RSA PRIVATE KEY-----' > tmp.pem
		sed '$d' ssh_key.pem | sed '$d' | sed '$d'| sed '$d'| tail -n+5  >> tmp.pem
		echo '-----END RSA PRIVATE KEY-----'>>tmp.pem
		rm -rf ssh_key.pem
		mkdir -p ~/.ssh
		mv tmp.pem ~/.ssh/id_rsa
		chmod 600 ~/.ssh/id_rsa

		echo "Copy the ssh key to id_rsa in home directory of root" >>${ARMLOGPATH}
		key_path=~/.ssh/id_rsa

		echo 'ssh key set to '$key_path >>${ARMLOGPATH}

	fi
}


setup_ansible_config() {

	TOPOLOGY_TYPE=""

	# This sets the delimiter for the array as ':'
	IFS=:
	hosts_ary=($HOST_NAMES)
	hosts_ary_length=${#hosts_ary[@]}
	echo $hosts_ary_length  >>${ARMLOGPATH}

	if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then

		cp -fr  /tmp/apigee/ansible-scripts/config/aio-config.txt /tmp/apigee/ansible-scripts/config/config.txt
		cp -fr  /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_1node /tmp/apigee/ansible-scripts/inventory/hosts
	        LB_IP_ALIAS=$VHOST_ALIAS
		
	elif [ "$DEPLOYMENT_TOPOLOGY" == "Medium"  ]; then
		TOPOLOGY_TYPE=EDGE_5node
		if [ "$hosts_ary_length" -lt 5 ]; then
			echo "Not enough hosts defined: " $DEPLOYMENT_TOPOLOGY >> ${ARMLOGPATH}
			exit 400
		fi
		cp -fr  /tmp/apigee/ansible-scripts/config/config5.txt /tmp/apigee/ansible-scripts/config/config.txt
		cp -fr  /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_5node /tmp/apigee/ansible-scripts/inventory/hosts
		
		TOPOLOGY_TYPE=EDGE_5node
		 
	elif [ "$DEPLOYMENT_TOPOLOGY" == "Large"  ]; then
		if [ "$hosts_ary_length" -lt "9" ]; then
			echo "Not enough hosts defined: " $DEPLOYMENT_TOPOLOGY >> ${ARMLOGPATH}
			exit 400
		fi
		cp -fr  /tmp/apigee/ansible-scripts/config/config9.txt /tmp/apigee/ansible-scripts/config/config.txt
		cp -fr  /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_9node /tmp/apigee/ansible-scripts/inventory/hosts
		

		TOPOLOGY_TYPE=EDGE_9node
	else
		echo "unsupported deployment: " $DEPLOYMENT_TOPOLOGY >> ${ARMLOGPATH}
		exit 400
	fi
	echo "deployment topology: " $TOPOLOGY_TYPE >> ${ARMLOGPATH}


	echo "Changing hosts in hosts and config file: " >> ${ARMLOGPATH}

	c=1
	for i in "${hosts_ary[@]}"
	do
		if [[ ${i} != 'empty' ]]; then
			key='HOST'$c'_INTERNALIP'
			echo $key  >>${ARMLOGPATH}
			sed -i.bak s/${key}/${i}/g /tmp/apigee/ansible-scripts/inventory/hosts
			sed -i.bak s/${key}/${i}/g /tmp/apigee/ansible-scripts/config/config.txt
			sed -i.bak s/${key}/${i}/g /tmp/apigee/ansible-scripts/config/grafana.txt
			sed -i.bak s/${key}/${i}/g /tmp/apigee/ansible-scripts/config/setup-org-prod.txt
			sed -i.bak s/${key}/${i}/g /tmp/apigee/ansible-scripts/config/setup-org-test.txt
			echo $i  >>${ARMLOGPATH}
			((c++))
		fi
	done

	echo "Changing configuration file with the details"

	cd /tmp/apigee/ansible-scripts/config
	sed -i.bak s/ADMIN_EMAIL=/ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g config.txt
	sed -i.bak s/ADMIN_EMAIL=/ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g setup-org-prod.txt
	sed -i.bak s/ADMIN_EMAIL=/ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g setup-org-test.txt

	sed -i.bak s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g config.txt
	sed -i.bak s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g setup-org-prod.txt
	sed -i.bak s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g setup-org-test.txt

	sed -i.bak s/ORG_NAME=/ORG_NAME="${ORG_NAME}"/g setup-org-prod.txt
	sed -i.bak s/ORG_NAME=/ORG_NAME="${ORG_NAME}"/g setup-org-test.txt

	sed -i.bak s/APIGEE_LDAPPW=/APIGEE_LDAPPW="${APW}"/g config.txt

	sed -i.bak s/LBDNS/"${LB_IP_ALIAS}"/g config.txt
	sed -i.bak s/LBDNS/"${LB_IP_ALIAS}"/g setup-org-prod.txt
	sed -i.bak s/LBDNS/"${LB_IP_ALIAS}"/g setup-org-test.txt

	echo "Changing SMTP Settings"
	sed -i.bak s/SKIP_SMTP=.*/SKIP_SMTP=${SKIP_SMTP}/g config.txt
	sed -i.bak s/SMTPHOST=.*/SMTPHOST=${SMTPHOST}/g config.txt
	sed -i.bak s/SMTPMAILFROM=.*/SMTPMAILFROM="\"${SMTPMAILFROM}\""/g config.txt
	sed -i.bak s/SMTPUSER=.*/SMTPUSER=${SMTPUSER}/g config.txt
	sed -i.bak s/SMTPPASSWORD=.*/SMTPPASSWORD=${SMTPPASSWORD}/g config.txt
	sed -i.bak s/SMTPSSL=.*/SMTPSSL=${SMTPSSL}/g config.txt
	sed -i.bak s/SMTPPORT=.*/SMTPPORT="${SMTPPORT}"/g config.txt

	echo "Changing configuration of dev portals"

	sed -i.bak s/DEVPORTAL_ADMIN_USERNAME=/DEVPORTAL_ADMIN_USERNAME="${APIGEE_ADMIN_EMAIL}"/g dp-config.txt
	sed -i.bak s/DEVPORTAL_ADMIN_PWD=/DEVPORTAL_ADMIN_PWD="${APW}"/g dp-config.txt
	sed -i.bak s/DEVPORTAL_ADMIN_EMAIL=/DEVPORTAL_ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g dp-config.txt

	sed -i.bak s/DEVADMIN_USER=/DEVADMIN_USER="${APIGEE_ADMIN_EMAIL}"/g dp-config.txt
	sed -i.bak s/DEVADMIN_PWD=/DEVADMIN_PWD="${APW}"/g dp-config.txt
	sed -i.bak s/EDGE_ORG=/EDGE_ORG="${ORG_NAME}"/g dp-config.txt
	sed -i.bak s/MGMTIP/${MSIP}/g dp-config.txt

	sed -i.bak s/SMTPHOST=.*/SMTPHOST=${SMTPHOST}/g dp-config.txt
	sed -i.bak s/SMTPMAILFROM=.*/SMTPMAILFROM="\"${SMTPMAILFROM}\""/g dp-config.txt
	sed -i.bak s/SMTPUSER=.*/SMTPUSER=${SMTPUSER}/g dp-config.txt
	sed -i.bak s/SMTPPASSWORD=.*/SMTPPASSWORD=${SMTPPASSWORD}/g dp-config.txt
	sed -i.bak s/SMTPSSL=.*/SMTPSSL=${SMTPSSL}/g dp-config.txt
	sed -i.bak s/SMTPPORT=.*/SMTPPORT="${SMTPPORT}"/g dp-config.txt


	if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then
	    sed -i.bak s/VHOST_BASEURL=.*//g setup-org-prod.txt
	    sed -i.bak s/VHOST_BASEURL=.*//g setup-org-test.txt
	fi

	if ["$SMTPUSER" == "apiadmin@apigee.com"]; then
		sed -i.bak s/SMTPUSER=.*//g config.txt
		sed -i.bak s/SMTPUSER=.*//g dp-config.txt
	fi
	if ["$SMTPUSER" == ""]; then
		sed -i.bak s/SMTPUSER=.*//g config.txt
	fi
	if ["$SMTPPASSWORD" == ""]; then
		sed -i.bak s/SMTPPASSWORD=.*//g config.txt
		sed -i.bak s/SMTPPASSWORD=.*//g dp-config.txt
	fi

	echo 'sed commands done' >> ${ARMLOGPATH}

}

run_ansible() {

	echo 'Running ansible commands' >> ${ARMLOGPATH}
	cd /tmp/apigee/ansible-scripts/playbook
	#Temporary fixes for playbook
	curl -O https://storage.googleapis.com/apigee/edge-prerequisite-playbook.yaml
	ansible-playbook -i ../inventory/hosts  edge-prerequisite-playbook.yaml  -u ${login_user} --private-key ${key_path} >>/tmp/ansible_output.log
	ansible-playbook --extra-vars "apigee_user=$REPO_USER apigee_password=$REPO_PASSWORD repohost=$REPO_HOST repoprotocol=$REPO_PROTOCOL repostage=$REPO_STAGE version=$EDGE_VERSION" -i ../inventory/hosts  -u ${login_user} --private-key ${key_path} edge-presetup-playbook.yaml >>/tmp/ansible_output.log
	ansible-playbook -i ../inventory/hosts  edge-components-setup-playbook.yaml  -u ${login_user} --private-key ${key_path}  >>/tmp/ansible_output.log
	echo "Ansible Scripts Executed"  >>${ARMLOGPATH}
}

echo 'script execution started at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}

echo 'Initializing variables' >>${ARMLOGPATH}

REPO_USER=$1
REPO_PASSWORD=$2
EDGE_VERSION=$3
FILE_BASEPATH=$4
USER_NAME=$5
APIGEE_ADMIN_EMAIL=$6
APW=$7
VHOST_ALIAS=$8
VHOST_NAME='default'
VHOST_PORT_PROD='9001'
VHOST_PORT_TEST='9002'
DEPLOYMENT_TOPOLOGY=$9
LB_IP_ALIAS=${10}
HOST_NAMES=${11}
LICENSE_TEXT=${12}
SSH_KEY=${13}
ORG_NAME=${14}
SMTPHOST=${15}
SMTPPORT=${16}
SMTPSSL=${17}
SMTPMAILFROM=${18}
SMTPUSER=${19}
SMTPPASSWORD=${20}
SKIP_SMTP="n"

login_user=$USER_NAME
MSIP=$(hostname -i)

echo 'script execution started at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}

echo "args: $*" >>${ARMLOGPATH}
echo 'Inititalized variables, ' $REPO_USER, $REPO_PASSWORD, $EDGE_VERSION, $FILE_BASEPATH, $VHOST_ALIAS, $EDGE_VERSION, $DEPLOYMENT_TOPOLOGY, $LB_IP_ALIAS, "Hosts: " $HOST_NAMES  >>${ARMLOGPATH}


#setup_variables
#install_apigee
#setup_ssh_key_and_license
#setup_ansible_config
#run_ansible

echo 'script execution ended at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}
