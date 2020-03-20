#sudo ./install-apigee.sh apigeetrial apigeetrial@apigee.com secret apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1:10.0.0.2:10.0.0.3:10.0.0.4:10.0.0.5 $LICENSE $SSH

mkdir -p /tmp/apigee/log
ARMLOGPATH=/tmp/apigee/log/armextension.log
echo 'executing the install script' >>${ARMLOGPATH}


initialize_variables() {

	echo 'Initializing variables' >>${ARMLOGPATH}

	REPO_USER=$1
	REPO_PASSWORD=$2
	EDGE_VERSION=$3
	FILE_BASEPATH=$4
	REPO_HOST="software.apigee.com"
    REPO_PROTOCOL="https"
    REPO_STAGE="release"

	USER_NAME=$5
	APIGEE_ADMIN_EMAIL=$6
	APW=$7
	MSIP=$8
	MSPUBLICIP=$9
	PGIP=${10}
	UEPUBLICIP=${11}
	SSH_KEY=${12}
	ORG_NAME=${13}
	DEPLOYMENT_TOPOLOGY=${14}
	SMTPHOST=${15}
	SMTPPORT=${16}
	SMTPSSL=${17}
	SMTPMAILFROM=${18}
	SMTPUSER=${19}
	SMTPPASSWORD=${20}
	SKIP_SMTP="n"

	login_user=$USER_NAME
	HOST_NAMES=$(hostname -i)

	echo 'script execution started at:'>>${ARMLOGPATH}
	echo $(date)>>${ARMLOGPATH}

	echo "args: $*" >>${ARMLOGPATH}
	echo 'Inititalized variables, ' $REPO_USER, $REPO_PASSWORD, $EDGE_VERSION, $FILE_BASEPATH, "Hosts: " $HOST_NAMES  >>${ARMLOGPATH}

}

get_ansible_files() {

	#Get ansible scripts in /tmp/apigee/ansible directory
	mkdir -p /tmp/apigee/ansible-scripts
	mkdir -p /tmp/apigee/ansible-scripts/inventory
	mkdir -p /tmp/apigee/ansible-scripts/playbook
	mkdir -p /tmp/apigee/ansible-scripts/config

	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_1node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_1node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_5node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_5node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_9node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_9node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_dpnode  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_dpnode
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_uenode  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_uenode


	curl -o /tmp/apigee/ansible-scripts/config/aio-config.txt  $FILE_BASEPATH/ansible-scripts/config/aio-config.txt
	curl -o /tmp/apigee/ansible-scripts/config/dp-config.txt  $FILE_BASEPATH/ansible-scripts/config/dp-config.txt
	curl -o /tmp/apigee/ansible-scripts/config/sso-config.txt  $FILE_BASEPATH/ansible-scripts/config/sso-config.txt
	curl -o /tmp/apigee/ansible-scripts/config/ue-config.txt  $FILE_BASEPATH/ansible-scripts/config/ue-config.txt	
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
	curl -o /tmp/apigee/ansible-scripts/playbook/ue-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ue-playbook.yaml	
	curl -o /tmp/apigee/ansible-scripts/playbook/orgsetup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/orgsetup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-prerequisite-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-prerequisite-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-presetup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-presetup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-components-setup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-components-setup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-setup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-setup-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-dashboard-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-dashboard-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-telegraf-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-telegraf-playbook.yaml
	curl -o /tmp/apigee/ansible-scripts/playbook/edge-uninstall-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-uninstall-playbook.yaml

}

setup_ssh_key2() {
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

	sudo mkdir -p /opt/apigee/customer/application/apigee-sso/jwt-keys
	cd /opt/apigee/customer/application/apigee-sso/jwt-keys/
	sudo openssl genrsa -out privkey.pem 2048
	sudo openssl rsa -pubout -in privkey.pem -out pubkey.pem
	sudo -R chown apigee:apigee /opt/apigee/customer/application/apigee-sso/jwt-keys
}

setup_ssh_key() {

	SSH_KEY=`echo ${SSH_KEY} | base64 --decode`

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
		#echo $SSH_KEY | tr " " "\n" > ssh_key.pem
		#dos2unix ssh_key.pem

		#This is all because the spaces in the bellow lines are also converted to new lines!
		#echo '-----BEGIN RSA PRIVATE KEY-----' > tmp.pem
		#sed '$d' ssh_key.pem | sed '$d' | sed '$d'| sed '$d'| tail -n+5  >> tmp.pem
		#echo '-----END RSA PRIVATE KEY-----'>>tmp.pem
		#rm -rf ssh_key.pem
		echo $SSH_KEY > ssh_key_ori.pem
		sed -E 's/(-+(BEGIN|END) (RSA|OPENSSH) PRIVATE KEY-+) *| +/\1\n/g' <<< "$SSH_KEY" > tmp.pem

		mkdir -p ~/.ssh
		mv tmp.pem ~/.ssh/id_rsa
		chmod 600 ~/.ssh/id_rsa

		echo "Copy the ssh key to id_rsa in home directory of root" >>${ARMLOGPATH}
		key_path=~/.ssh/id_rsa

		echo 'ssh key set to '$key_path >>${ARMLOGPATH}

	fi

	sudo mkdir -p /opt/apigee/customer/application/apigee-sso/jwt-keys
	cd /opt/apigee/customer/application/apigee-sso/jwt-keys/
	sudo openssl genrsa -out privkey.pem 2048
	sudo openssl rsa -pubout -in privkey.pem -out pubkey.pem
	sudo -R chown apigee:apigee /opt/apigee/customer/application/apigee-sso/jwt-keys
}

setup_ansible() {

	yum install wget -y
	yum install unzip -y
	yum install curl -y
	#yum install ansible -y

	rpm -e epel-release
	sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	rpm -ivh epel-release-latest-7.noarch.rpm


	curl -O https://storage.googleapis.com/apigee/ansible-2.3.0.0-3.el7.noarch.rpm
	yum install ansible-2.3.0.0-3.el7.noarch.rpm -y


	setenforce 0 >> /tmp/setenforce.out
	cat /etc/selinux/config > /tmp/beforeSelinux.out
	sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
	cat /etc/selinux/config > /tmp/afterSeLinux.out

	yum install -y iptables-services
	systemctl mask firewalld
	systemctl enable iptables
	systemctl stop firewalld
	systemctl start iptables
	iptables --flush
	service iptables save

	echo "ALL ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

}

setup_ansible_config() {
	echo "Changing configuration of dev portals"
	cd /tmp/apigee/ansible-scripts/config

	sed -i.bak s/ADMIN_EMAIL=/ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g sso-config.txt
	sed -i.bak s/ADMIN_EMAIL=/ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g ue-config.txt

	sed -i.bak s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g sso-config.txt
	sed -i.bak s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g ue-config.txt

	sed -i.bak s/SMTPHOST=.*/SMTPHOST=${SMTPHOST}/g sso-config.txt
	sed -i.bak s/SMTPMAILFROM=.*/SMTPMAILFROM="\"${SMTPMAILFROM}\""/g sso-config.txt
	sed -i.bak s/SMTPUSER=.*/SMTPUSER=${SMTPUSER}/g sso-config.txt
	sed -i.bak s/SMTPPASSWORD=.*/SMTPPASSWORD=${SMTPPASSWORD}/g sso-config.txt
	sed -i.bak s/SMTPSSL=.*/SMTPSSL=${SMTPSSL}/g sso-config.txt
	sed -i.bak s/SMTPPORT=.*/SMTPPORT="${SMTPPORT}"/g sso-config.txt
	sed -i.bak s/SMTPHOST=.*/SMTPHOST=${SMTPHOST}/g ue-config.txt
	sed -i.bak s/SMTPMAILFROM=.*/SMTPMAILFROM="\"${SMTPMAILFROM}\""/g ue-config.txt
	sed -i.bak s/SMTPUSER=.*/SMTPUSER=${SMTPUSER}/g ue-config.txt
	sed -i.bak s/SMTPPASSWORD=.*/SMTPPASSWORD=${SMTPPASSWORD}/g ue-config.txt
	sed -i.bak s/SMTPSSL=.*/SMTPSSL=${SMTPSSL}/g ue-config.txt
	sed -i.bak s/SMTPPORT=.*/SMTPPORT="${SMTPPORT}"/g ue-config.txt

	if ["$SMTPUSER" == "apiadmin@apigee.com"]; then
		sed -i.bak s/SMTPUSER=.*//g sso-config.txt
		sed -i.bak s/SMTPUSER=.*//g ue-config.txt

	fi
	if ["$SMTPUSER" == ""]; then
		sed -i.bak s/SMTPUSER=.*//g sso-config.txt
		sed -i.bak s/SMTPUSER=.*//g ue-config.txt

	fi
	if ["$SMTPPASSWORD" == ""]; then
		sed -i.bak s/SMTPPASSWORD=.*//g sso-config.txt
		sed -i.bak s/SMTPPASSWORD=.*//g ue-config.txt

	fi

	if [[ "$PGIP" == "empty" ]]; then
		PGIP=$MSIP
	fi

    sed -i.bak s/HOST1_INTERNALIP/${MSIP}/g sso-config.txt
    sed -i.bak s/HOST2_INTERNALIP/${PGIP}/g sso-config.txt
    sed -i.bak s/HOST3_EXTERNALIP/${UEPUBLICIP}/g sso-config.txt

    sed -i.bak s/HOST1_INTERNALIP/${MSIP}/g ue-config.txt
    sed -i.bak s/HOST2_INTERNALIP/${HOST_NAMES}/g ue-config.txt
    sed -i.bak s/HOST3_EXTERNALIP/${UEPUBLICIP}/g ue-config.txt

	cp -fr  /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_uenode /tmp/apigee/ansible-scripts/inventory/hosts

	sed -i.bak s/HOST1_INTERNALIP/${HOST_NAMES}/g /tmp/apigee/ansible-scripts/inventory/hosts
	sed -i.bak s/HOST2_INTERNALIP/${HOST_NAMES}/g /tmp/apigee/ansible-scripts/inventory/hosts
	
}

run_ansible() {

	cd /tmp/apigee/ansible-scripts/playbook

	ansible-playbook -i ../inventory/hosts  edge-prerequisite-playbook.yaml  -u ${login_user} --private-key ${key_path} >>/tmp/ansible_output.log
	ansible-playbook --extra-vars "apigee_user=$REPO_USER apigee_password=$REPO_PASSWORD repohost=$REPO_HOST repoprotocol=$REPO_PROTOCOL repostage=$REPO_STAGE version=$EDGE_VERSION" -i ../inventory/hosts  -u ${login_user} --private-key ${key_path} edge-presetup-playbook.yaml >>/tmp/ansible_output.log
	ansible-playbook -i ../inventory/hosts  ue-playbook.yaml  -u ${login_user} --private-key ${key_path}  >>/tmp/ansible_output.log
	
	echo "Ansible Scripts Executed"  >>${ARMLOGPATH}

}

initialize_variables "$@"
get_ansible_files
setup_ssh_key
setup_ansible
setup_ansible_config
run_ansible


echo 'script execution ended at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}
