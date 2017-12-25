#sudo ./install-apigee.sh apigeetrial apigeetrial@apigee.com secret apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1:10.0.0.2:10.0.0.3:10.0.0.4:10.0.0.5 $LICENSE $SSH

echo 'executing the install script' >>${ARMLOGPATH}
mkdir -p /tmp/apigee/log
ARMLOGPATH=/tmp/apigee/log/armextension.log
echo "Changing the ansible log location"
sed -i "s|./ansible.log|/tmp/apigee/log/ansible.log|g" /tmp/apigee/ansible-scripts/playbook/ansible.cfg
echo "setting the installation log file to log directory"
ln -Ts /tmp/setup-root.log /tmp/apigee/log/setup-root.log


echo 'Initializing variables' >>${ARMLOGPATH}

USER_NAME=$1
ORG_NAME=$1
APIGEE_ADMIN_EMAIL=$2
APW=$3
VHOST_ALIAS=$4
VHOST_NAME='default'
VHOST_PORT_PROD='9001'
VHOST_PORT_TEST='9002'
EDGE_VERSION='4.17.09'
DEPLOYMENT_TOPOLOGY=$5
LB_IP_ALIAS=$6
HOST_NAMES=$7
LICENSE_TEXT=$8
SSH_KEY=$9

login_user=$USER_NAME
MSIP=$(hostname -i)

echo 'script execution started at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}

echo "args: $*" >>${ARMLOGPATH}
echo 'Inititalized variables, ' $VHOST_ALIAS, $EDGE_VERSION, $DEPLOYMENT_TOPOLOGY, $LB_IP_ALIAS, "Hosts: " $HOST_NAMES  >>${ARMLOGPATH}


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
	echo $SSH_KEY | tr " " "\n"> ssh_key.pem
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

echo "Changing configuration of dev portals"
sed -i.bak s/DEVPORTAL_ADMIN_USERNAME=/DEVPORTAL_ADMIN_USERNAME="${APIGEE_ADMIN_EMAIL}"/g dp-config.txt
sed -i.bak s/DEVPORTAL_ADMIN_PWD=/DEVPORTAL_ADMIN_PWD="${APW}"/g dp-config.txt
sed -i.bak s/DEVPORTAL_ADMIN_EMAIL=/DEVPORTAL_ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g dp-config.txt

sed -i.bak s/DEVADMIN_USER=/DEVADMIN_USER="${APIGEE_ADMIN_EMAIL}"/g dp-config.txt
sed -i.bak s/DEVADMIN_PWD=/DEVADMIN_PWD="${APW}"/g dp-config.txt
sed -i.bak s/EDGE_ORG=/EDGE_ORG="${ORG_NAME}"/g dp-config.txt
sed -i.bak s/MGMTIP/${MSIP}/g dp-config.txt

if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then
    sed -i.bak s/VHOST_BASEURL=.*//g setup-org-prod.txt
    sed -i.bak s/VHOST_BASEURL=.*//g setup-org-test.txt
fi

echo 'sed commands done' >> ${ARMLOGPATH}
echo 'Running ansible commands' >> ${ARMLOGPATH}

cd /tmp/apigee/ansible-scripts/playbook
ansible-playbook -i ../inventory/hosts  edge-prerequisite-playbook.yaml  -u ${login_user} --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
ansible-playbook -i ../inventory/hosts  edge-components-setup-playbook.yaml  -u ${login_user} --private-key ${key_path} -vvvv >>/tmp/ansible_output.log

echo "Ansible Scripts Executed"  >>${ARMLOGPATH}
firewall-cmd --zone=public --add-port=9000/tcp --permanent
firewall-cmd --zone=public --add-port=9001/tcp --permanent
firewall-cmd --zone=public --add-port=9002/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload

echo 'script execution ended at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}
