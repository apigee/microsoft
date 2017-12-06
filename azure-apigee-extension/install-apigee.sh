FTP_USER=$1
FTP_PASSWORD=$2
EDGE_VERSION=$3
#FILE_BASEPATH="https://raw.githubusercontent.com/apigee/microsoft/16x/azure-apigee-extension"
FILE_BASEPATH=$4


FTP_PASSWORD=`echo ${FTP_PASSWORD} | base64 --decode`

mkdir -p /tmp/apigee
mkdir -p /tmp/apigee/log
ln -Ts /tmp/setup-root.log /tmp/apigee/log/setup-root.log

cd /tmp/apigee


yum install wget -y
yum install unzip -y
yum install curl -y
#yum install ansible -y
curl -O https://storage.googleapis.com/apigee/ansible-2.3.0.0-3.el7.noarch.rpm
yum install ansible-2.3.0.0-3.el7.noarch.rpm -y

sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off
echo "ALL ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers


curl https://software.apigee.com/bootstrap_${EDGE_VERSION}.sh -o /tmp/apigee/bootstrap_${EDGE_VERSION}.sh
chmod 777 /tmp/apigee/bootstrap_${EDGE_VERSION}.sh
/tmp/apigee/bootstrap_${EDGE_VERSION}.sh apigeeuser=${FTP_USER} apigeepassword=${FTP_PASSWORD} JAVA_FIX=I
/opt/apigee/apigee-service/bin/apigee-service apigee-mirror install
/opt/apigee/apigee-service/bin/apigee-service apigee-mirror sync --only-new-rpms
chmod 777 /opt/apigee/data/apigee-mirror/repos/bootstrap_${EDGE_VERSION}.sh
/opt/apigee/data/apigee-mirror/repos/bootstrap_${EDGE_VERSION}.sh apigeeprotocol="file://" apigeerepobasepath=/opt/apigee/data/apigee-mirror/repos

/opt/apigee/apigee-service/bin/apigee-service apigee-setup install
/opt/apigee/apigee-service/bin/apigee-service apigee-provision install
/opt/apigee/apigee-service/bin/apigee-service apigee-validate install


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


cat /dev/null > /etc/yum/vars/apigeepassword
cat /dev/null > /etc/yum/vars/apigeeuser
cat /dev/null > /etc/yum/vars/apigeecredentialswithat
sed -i 's^enabled=1^enabled=0^g' /etc/yum.repos.d/epel.repo || true

