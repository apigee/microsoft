#sudo ./install-apigee.sh apigeetrial apigeetrial@apigee.com secret apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1:10.0.0.2:10.0.0.3:10.0.0.4:10.0.0.5 $LICENSE $SSH

echo 'executing the install script' >>${ARMLOGPATH}
ARMLOGPATH=/tmp/apigee/armextension.log
BASE_GIT_URL='https://raw.githubusercontent.com/apigee/microsoft/16x/apigee-edge-arm-template/'

echo 'Initializing variables' >>${ARMLOGPATH}

USER_NAME=$1
ORG_NAME=$1
APIGEE_ADMIN_EMAIL=$2
APW=$3
VHOST_ALIAS=$4
VHOST_NAME='default'
VHOST_PORT_PROD='9001'
VHOST_PORT_TEST='9002'
EDGE_VERSION='4.16.05'
DEPLOYMENT_TOPOLOGY=$5
LB_IP_ALIAS=$6
HOST_NAMES=$7
LICENSE_TEXT=$8
SSH_KEY=$9

login_user=$USER_NAME

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


TOPOLOGY_TYPE=""

# This sets the delimiter for the array as ':'
IFS=:
hosts_ary=($HOST_NAMES)
hosts_ary_length=${#hosts_ary[@]}
echo $hosts_ary_length  >>${ARMLOGPATH}

if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then

	cp -fr  /tmp/apigee/ansible-scripts/config/aio-config.txt /tmp/apigee/ansible-scripts/config/config.txt
	cp -fr  /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_1node /tmp/apigee/ansible-scripts/inventory/hosts
        LB_IP_ALIAS=VHOST_ALIAS
	
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


echo 'sed commands done' >> ${ARMLOGPATH}
echo 'Running ansible commands' >> ${ARMLOGPATH}

cd /tmp/apigee/ansible-scripts/playbook
ansible-playbook -i ../inventory/hosts  edge-components-setup-playbook.yaml  -u ${login_user} --private-key ${key_path} -vvvv >>/tmp/ansible_output.log

echo "Ansible Scripts Executed"  >>${ARMLOGPATH}

echo 'script execution ended at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}
