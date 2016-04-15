#sudo ./install-apigee.sh apigeetrial secret apigeetrial apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1,10.0.0.2,10.0.0.3,10.0.0.4,10.0.0.5 $LICENSE $SSH


echo 'executing the install script' >>/tmp/armscript.log

BASE_GIT_URL='https://raw.githubusercontent.com/apigee/microsoft/master/apigee-edge-arm-template/'

USER_NAME=$1
APW=$2
ORG_NAME=$3
VHOST_ALIAS=$4
ENV_NAME='test'
VHOST_NAME='default'
VHOST_PORT='9002'
EDGE_VERSION='4.15.07.03'



DEPLOYMENT_TOPOLOGY=$5
LB_IP_ALIAS=$6

HOST_NAMES=$7

LICENSE_TEXT=$8
SSH_KEY=$9

echo 'script execution started at:'>>/tmp/armscript.log
echo $(date)>>/tmp/armscript.log
echo 'Inititalized variables, ' $VHOST_ALIAS, $EDGE_VERSION, $DEPLOYMENT_TOPOLOGY, $LB_IP_ALIAS, "Hosts: " $HOST_NAMES  >>/tmp/armscript.log


cd /tmp/apigee
echo 'in tmp/apigee folder' >> /tmp/armscript.log

rm -rf license.txt
echo $LICENSE_TEXT > license.txt
echo $LICENSE_TEXT > ../license.txt

echo $SSH_KEY > ssh_key.pem
echo $SSH_KEY > ../ssh_key.pem



if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then

	echo "deploying a 1 node setup" >> /tmp/armscript.log


	sed -i s/ADMIN_EMAIL=/ADMIN_EMAIL="${USER_NAME}"/g opdk.conf
	sed -i s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g opdk.conf
	sed -i s/APIGEE_LDAPPW=/APIGEE_LDAPPW="${APW}"/g opdk.conf

	echo 'sed commands done' >> /tmp/armscript.log

	unzip apigee-edge-${EDGE_VERSION}.zip
	echo 'unzip done' >> /tmp/armscript.log

	cd apigee-edge-${EDGE_VERSION}
	echo 'in edge folder, installing' >> /tmp/armscript.log
	./apigee-install.sh -j /usr/java/default -r /opt -d /opt

	echo 'installing unpacked edge binaries' >> /tmp/armscript.log
	/opt/apigee4/share/installer/apigee-setup.sh -p aio -f /tmp/opdk.conf



	#/opt/apigee4/share/installer/apigee-setup.sh -p ds -f /tmp/opdk.conf

	#/opt/apigee4/share/installer/apigee-setup.sh -p rmp -f /tmp/opdk.conf

	#/opt/apigee4/share/installer/apigee-setup.sh -p sax -f /tmp/opdk.conf

	#update the setup-org
	cp -fr /tmp/apigee/setup-org.sh /opt/apigee4/bin/setup-org.sh
	/opt/apigee4/bin/setup-org.sh ${USER_NAME} ${APW} ${ORG_NAME} ${ENV_NAME} ${VHOST_NAME} ${VHOST_PORT} ${VHOST_ALIAS}

	echo 'script execution ended at:'>>/tmp/armscript.log
	echo $(date)>>/tmp/armscript.log
else
	TOPOLOGY_TYPE=""
	if [ "$DEPLOYMENT_TOPOLOGY" == "Medium"  ]; then
		TOPOLOGY_TYPE=EDGE_5node
	elif [ "$DEPLOYMENT_TOPOLOGY" == "Large"  ]; then
		TOPOLOGY_TYPE=EDGE_9node
	else
		echo "unsupported deployment: " $DEPLOYMENT_TOPOLOGY >> /tmp/armscript.log
		exit 400
	fi
	echo "deployment topology: " $TOPOLOGY_TYPE >> /tmp/armscript.log




	cd /tmp/apigee/apigee_install_scripts/prerpm_install/playbooks
	automation_path='/tmp/apigee/apigee_install_scripts/prerpm_install'
	hosts_path='/tmp/apigee/apigee_install_scripts/common/source'
	host2_path='/tmp/apigee/apigee_install_scripts/common/source'
	WORKSPACE='/tmp/apigee/apigee_install_scripts/prerpm_install/playbooks'
	key_path='/tmp/ssh_key.pem'
	mp_pod_name='gateway'
	resource_path='/tmp/apigee'
	smtp_conf=y

	topology_type=$1
	login_user=$2



	export ANSIBLE_HOST_KEY_CHECKING=False
	#cp /tmp/apigee/apigee-edge-4.15.07.03.zip /tmp

	echo "This is right before ansible-playbook"
	PARAMS="key_pair=new-opdk topology_type=${topology_type} installation_type=$installation_type workspace=${WORKSPACE} smtp_conf=${smtp_conf}  login_user=${login_user} package1_name=${installer}  jdk_version=${java_version} pem_key_path=$key_path mp_pod_name=${mp_pod_name} res_ouput_directory=$resource_path login_user=${login_user} file_system=$filesystem  disk_space=$disk_space apigee_repo_username=${apigee_repo_username} apigee_repo_password=${apigee_repo_password} apigee_stage=${apigee_stage} apigee_repo_url=${apigee_repo_url}"


	/usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/update-hostnamei.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv
	/usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/mount_disk_azure.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv
	# /usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/generate_silent_config.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv
	# /usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/installation_setup.yml -M ${automation_path}/playbooks  -u ${login_user}  -e "${PARAMS}" --private-key ${key_path} -vvvv
	# /usr/local/bin/ansible-playbook -i ${host2_path}/host2  ${automation_path}/playbooks/install_apigee_multinode.yml -M ${automation_path}/playbooks  -u ${login_user}  -e "${PARAMS}" --private-key ${key_path} -vvvv
	# /usr/local/bin/ansible-playbook -i ${host2_path}/host2  ${automation_path}/playbooks/postgres_master_slave_conf.yml -M ${automation_path}/playbooks -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv



fi
