#sudo ./install-apigee.sh apigeetrial apigeetrial@apigee.com secret apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1:10.0.0.2:10.0.0.3:10.0.0.4:10.0.0.5 $LICENSE $SSH

mkdir -p /tmp/apigee/log
ARMLOGPATH=/tmp/apigee/log/armextension.log
echo 'executing the install script' >>${ARMLOGPATH}
#echo "Changing the ansible log location"
#sed -i "s|./ansible.log|/tmp/apigee/log/ansible.log|g" /tmp/apigee/ansible-scripts/playbook/ansible.cfg
#echo "setting the installation log file to log directory"
#ln -Ts /tmp/setup-root.log /tmp/apigee/log/setup-root.log


echo 'Initializing variables' >>${ARMLOGPATH}

USER_NAME=$1
APIGEE_ADMIN_EMAIL=$2
APW=$3
MSIP=$4
ORG_NAME=${5}
SMTPHOST=${6}
SMTPPORT=${7}
SMTPSSL=${8}
SMTPUSER=${9}
SMTPPASSWORD=${10}
SMTPMAILFROM=${11}
SKIP_SMTP="n"

login_user=$USER_NAME

echo 'script execution started at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}

echo "args: $*" >>${ARMLOGPATH}

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

#Manually copy the dp config to /tmp/apigee folder
cp -fr /tmp/apigee/ansible-scripts/config/dp-config.txt /tmp/apigee/dp-config.txt
cd /tmp/apigee/ansible-scripts/playbook

#ansible-playbook -i ../inventory/hosts  dp-playbook.yaml  -u ${login_user} --private-key ${key_path}  >>/tmp/ansible_output.log
/opt/apigee/apigee-setup/bin/setup.sh -p pdb -f /tmp/apigee/dp-config.txt
/opt/apigee/apigee-setup/bin/setup.sh -p dp -f /tmp/apigee/dp-config.txt


echo "Ansible Scripts Executed"  >>${ARMLOGPATH}


echo 'script execution ended at:'>>${ARMLOGPATH}
echo $(date)>>${ARMLOGPATH}
