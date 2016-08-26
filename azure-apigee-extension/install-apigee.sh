FILE_BASEPATH="https://raw.githubusercontent.com/apigee/microsoft/16x/azure-apigee-extension"
FTP_USER=$1
FTP_PASSWORD=$2
EDGE_VERSION=$3

FTP_PASSWORD=`echo ${FTP_PASSWORD} | base64 --decode`

mkdir -p /tmp/apigee
cd /tmp/apigee


yum install wget -y
yum install unzip -y
yum install curl -y

yum install python-setuptools -y
easy_install pip -y
pip install boto
yum install libselinux-python -y
pip install httplib2


setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off


curl -o /tmp/apigee/config.txt "${FILE_BASEPATH}"/config.txt
curl https://software.apigee.com/bootstrap_${EDGE_VERSION}.sh -o /tmp/apigee/bootstrap_${EDGE_VERSION}.sh
chmod 777 /tmp/apigee/bootstrap_${EDGE_VERSION}.sh
/tmp/apigee/bootstrap_${EDGE_VERSION}.sh apigeeuser=${FTP_USER} apigeepassword=${FTP_PASSWORD} JAVA_FIX=I
/opt/apigee/apigee-service/bin/apigee-service apigee-setup install
/opt/apigee/apigee-service/bin/apigee-service apigee-provision install
/opt/apigee/apigee-service/bin/apigee-service apigee-validate install

yum install apigee-cassandra -y
yum install apigee-zookeeper -y
yum install apigee-openldap -y
yum install edge-management-server -y
yum install edge-ui -y
yum install edge-router -y
yum install edge-message-processor -y
yum install apigee-postgresql -y
yum install edge-postgres-server -y
yum install apigee-qpidd -y
yum install edge-qpid-server -y

curl -o /tmp/apigee/epel-release-6-8.noarch.rpm  http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh /tmp/apigee/epel-release-6-8.noarch.rpm
yum install ansible -y

#Get ansible scripts in /tmp/apigee/ansible directory
mkdir /tmp/apigee/ansible-scripts
mkdir /tmp/apigee/ansible-scripts/inventory
mkdir /tmp/apigee/ansible-scripts/playbook
mkdir /tmp/apigee/ansible-scripts/config

curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_1node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_1node
curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_5node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_5node
curl -o /tmp/apigee/ansible-scripts/inventory/hosts_EDGE_9node  $FILE_BASEPATH/ansible-scripts/inventory/hosts_EDGE_9node

curl -o /tmp/apigee/ansible-scripts/config/aio-config.txt  $FILE_BASEPATH/ansible-scripts/config/aio-config.txt
curl -o /tmp/apigee/ansible-scripts/config/config5.txt  $FILE_BASEPATH/ansible-scripts/config/config5.txt
curl -o /tmp/apigee/ansible-scripts/config/config9.txt  $FILE_BASEPATH/ansible-scripts/config/config9.txt

curl -o /tmp/apigee/ansible-scripts/playbook/ansible.cfg  $FILE_BASEPATH/ansible-scripts/playbook/ansible.cfg
curl -o /tmp/apigee/ansible-scripts/playbook/ds-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ds-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/rmp-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/rmp-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/ps-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ps-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/qs-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/qs-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/ms-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/ms-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/orgsetup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/orgsetup-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/edge-prerequisite-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-prerequisite-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/edge-components-setup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-components-setup-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/edge-setup-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-setup-playbook.yaml
curl -o /tmp/apigee/ansible-scripts/playbook/edge-uninstall-playbook.yaml  $FILE_BASEPATH/ansible-scripts/playbook/edge-uninstall-playbook.yaml


cat /dev/null > /etc/yum/vars/apigeepassword
cat /dev/null > /etc/yum/vars/apigeeuser
cat /dev/null > /etc/yum/vars/apigeecredentialswithat
sed -i 's^enabled=1^enabled=0^g' /etc/yum.repos.d/epel.repo || true

