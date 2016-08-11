FILE_BASEPATH="https://raw.githubusercontent.com/apigee/microsoft/16x/azure-apigee-extension"
FTP_USER=$1
FTP_PASSWORD=$2
LICENSE_PATH=$3
USER_NAME=$4
APW=$5
ORG_NAME=$6
ENV_NAME=$7
VHOST_NAME=$8
VHOST_PORT=$9
VHOST_ALIAS=${10}
FTP_SERVER=${11}
FTP_EDGE_BINARY_PATH=${12}

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
curl -o /tmp/apigee/license.txt -u "${FTP_USER}:${FTP_PASSWORD}" "${FTP_SERVER}${LICENSE_PATH}"
curl https://software.apigee.com/bootstrap_4.16.05.sh -o /tmp/bootstrap_4.16.05.sh
chmod 777 /tmp/bootstrap_4.16.05.sh
/tmp/bootstrap_4.16.05.sh apigeeuser=$FTP_USER apigeepassword=$FTP_PASSWORD JAVA_FIX=I
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

curl -o /tmp/apigee/epel-release-7-8.noarch.rpm  http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
rpm -ivh /tmp/apigee/epel-release-7-8.noarch.rpm
yum install ansible -y

#curl -v -j -O -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm"
#rpm -i jdk-7u79-linux-x64.rpm
#curl -o /tmp/apigee/apigee-edge-${EDGE_VERSION}.zip -u "${FTP_USER}:${FTP_PASSWORD}" "${FTP_SERVER}${FTP_EDGE_BINARY_PATH}"
#curl -o /tmp/apigee/license.txt -u "${FTP_USER}:${FTP_PASSWORD}" "${FTP_SERVER}${LICENSE_PATH}"
#curl -o /tmp/apigee/setup-org.sh "${FILE_BASEPATH}/setup-org.sh"


#yum install gcc -y
#yum install zlib-devel -y
#yum install openssl openssl-devel -y

#wget 'http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz'
#xz -d Python-2.7.6.tar.xz
#tar -xvf Python-2.7.6.tar
#cd Python-2.7.6
#./configure --prefix=/usr/local 
#make
#make altinstall
#cd /tmp/apigee
#echo 'Python updated' >> /tmp/armtemplateoutput.log
#/tmp/apigee/Python-2.7.6/python --version >> /tmp/armtemplateoutput.log

#wget --no-check-certificate 'https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz'
#tar -xvf setuptools-1.4.2.tar.gz
#cd setuptools-1.4.2
#/tmp/apigee/Python-2.7.6/python setup.py install

#cd /tmp/apigee
#wget https://bootstrap.pypa.io/get-pip.py
#/tmp/apigee/Python-2.7.6/python get-pip.py

#yum install python-setuptools -y

#/usr/local/bin/pip install boto
#yum install libselinux-python -y
#/usr/local/bin/pip install httplib2
#/usr/local/bin/pip install simplejson


#/usr/local/bin/pip install ansible

#echo 'installed ansible' >> /tmp/armtemplateoutput.log

#sed -i 's/\/sbin:\/bin:\/usr\/sbin:\/usr\/bin/\/usr\/local\/bin:\/tmp\/apigee\/Python-2.7.6:\/sbin:\/bin:\/usr\/sbin:\/usr\/bin/g' /etc/sudoers


# cd /tmp/apigee
# unzip apigee-edge-${EDGE_VERSION}.zip
# cd apigee-edge-${EDGE_VERSION}
# ./apigee-install.sh -j /usr/java/default -r /opt -d /opt

#sed -i s/ADMIN_EMAIL=/ADMIN_EMAIL="${USER_NAME}"/g opdk.conf
#sed -i s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g opdk.conf
#sed -i s/APIGEE_LDAPPW=/APIGEE_LDAPPW="${APW}"/g opdk.conf


#/opt/apigee4/share/installer/apigee-setup.sh -p aio -f /tmp/opdk.conf
#update the setup-org
#cp -fr /tmp/setup-org.sh /opt/apigee4/bin/setup-org.sh
#/opt/apigee4/bin/setup-org.sh ${USER_NAME} ${APW} ${ORG_NAME} ${ENV_NAME} ${VHOST_NAME} ${VHOST_PORT} ${VHOST_ALIAS}

#/opt/apigee4/bin/setup-org.sh opdk@apigee.com Secret123 demo test default 9001 apigeeedge9node.westus.cloudapp.azure.com



