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
	ORG_NAME=${9}
	SMTPHOST=${10}
	SMTPPORT=${11}
	SMTPSSL=${12}
	SMTPMAILFROM=${13}
	SMTPUSER=${14}
	SMTPPASSWORD=${15}
	SKIP_SMTP="n"

	login_user=$USER_NAME
	HOST_NAMES=$(hostname -i)

	echo 'script execution started at:'>>${ARMLOGPATH}
	echo $(date)>>${ARMLOGPATH}

	echo "args: $*" >>${ARMLOGPATH}
	echo 'Inititalized variables, ' $REPO_USER, $REPO_PASSWORD, $EDGE_VERSION, $FILE_BASEPATH, "Hosts: " $HOST_NAMES  >>${ARMLOGPATH}

}

install_apigee() {

	#Get ansible scripts in /tmp/apigee/ansible directory
	mkdir -p /tmp/apigee/ansible-scripts
	mkdir -p /tmp/apigee/ansible-scripts/inventory
	mkdir -p /tmp/apigee/ansible-scripts/playbook
	mkdir -p /tmp/apigee/ansible-scripts/config

	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_1node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_1node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_5node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_5node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_9node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_9node
	curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_dpnode  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_dpnode


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

setup_ssh_key() {
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

	if ["$SMTPUSER" == "apiadmin@apigee.com"]; then
		sed -i.bak s/SMTPUSER=.*//g /tmp/apigee/dp-config.txt
	fi
	if ["$SMTPUSER" == ""]; then
		sed -i.bak s/SMTPUSER=.*//g /tmp/apigee/dp-config.txt
	fi
	if ["$SMTPPASSWORD" == ""]; then
		sed -i.bak s/SMTPPASSWORD=.*//g /tmp/apigee/dp-config.txt
	fi

	cp -fr  /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_dpnode /tmp/apigee/ansible-scripts/inventory/hosts

	IFS=:
	hosts_ary=($HOST_NAMES)
	hosts_ary_length=${#hosts_ary[@]}
	echo $hosts_ary_length  >>${ARMLOGPATH}

	c=1
	for i in "${hosts_ary[@]}"
	do
		if [[ ${i} != 'empty' ]]; then
			key='HOST'$c'_INTERNALIP'
			echo $key  >>${ARMLOGPATH}
			sed -i.bak s/${key}/${i}/g /tmp/apigee/ansible-scripts/inventory/hosts
			echo $i  >>${ARMLOGPATH}
			((c++))
		fi
	done

	#Manually copy the dp config to /tmp/apigee folder
	cp -fr /tmp/apigee/ansible-scripts/config/dp-config.txt /tmp/apigee/dp-config.txt
}

run_ansible() {

	cd /tmp/apigee/ansible-scripts/playbook

	ansible-playbook -i ../inventory/hosts  edge-prerequisite-playbook.yaml  -u ${login_user} --private-key ${key_path} >>/tmp/ansible_output.log
	ansible-playbook --extra-vars "apigee_user=$REPO_USER apigee_password=$REPO_PASSWORD repohost=$REPO_HOST repoprotocol=$REPO_PROTOCOL repostage=$REPO_STAGE version=$EDGE_VERSION" -i ../inventory/hosts  -u ${login_user} --private-key ${key_path} edge-presetup-playbook.yaml >>/tmp/ansible_output.log

	ansible-playbook -i ../inventory/hosts  dp-playbook.yaml  -u ${login_user} --private-key ${key_path}  >>/tmp/ansible_output.log
	#/opt/apigee/apigee-setup/bin/setup.sh -p pdb -f /tmp/apigee/dp-config.txt
	#/opt/apigee/apigee-setup/bin/setup.sh -p dp -f /tmp/apigee/dp-config.txt

	echo "Ansible Scripts Executed"  >>${ARMLOGPATH}

}

initialize_variables "$@"
install_apigee
setup_ssh_key
setup_ansible
setup_ansible_config
run_ansible


echo 'script execution ended at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}
