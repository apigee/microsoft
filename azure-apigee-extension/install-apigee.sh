FILE_BASEPATH="https://raw.githubusercontent.com/apigee/microsoft/master/azure-apigee-extension"
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
EDGE_VERSION=${13}


FTP_PASSWORD=`echo ${FTP_PASSWORD} | base64 --decode`

yum install wget -y
yum install unzip -y
yum install curl -y

setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off


curl -v -j -O -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm"
rpm -i jdk-7u79-linux-x64.rpm
curl -o /tmp/apigee-edge-${EDGE_VERSION}.zip -u "${FTP_USER}:${FTP_PASSWORD}" "${FTP_SERVER}${FTP_EDGE_BINARY_PATH}"
curl -o /tmp/license.txt -u "${FTP_USER}:${FTP_PASSWORD}" "${FTP_SERVER}${LICENSE_PATH}"
curl -o /tmp/setup-org.sh "${FILE_BASEPATH}/setup-org.sh"
curl -o /tmp/opdk.conf "${FILE_BASEPATH}/opdk.conf"
curl -o /tmp/CentOS-Base.repo "${FILE_BASEPATH}/CentOS-Base.repo"
cp -fr /tmp/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
cd /tmp

sed -i s/ADMIN_EMAIL=/ADMIN_EMAIL="${USER_NAME}"/g opdk.conf
sed -i s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g opdk.conf
sed -i s/APIGEE_LDAPPW=/APIGEE_LDAPPW="${APW}"/g opdk.conf

unzip apigee-edge-${EDGE_VERSION}.zip
cd apigee-edge-${EDGE_VERSION}
./apigee-install.sh -j /usr/java/default -r /opt -d /opt
/opt/apigee4/share/installer/apigee-setup.sh -p aio -f /tmp/opdk.conf
#update the setup-org
cp -fr /tmp/setup-org.sh /opt/apigee4/bin/setup-org.sh
/opt/apigee4/bin/setup-org.sh ${USER_NAME} ${APW} ${ORG_NAME} ${ENV_NAME} ${VHOST_NAME} ${VHOST_PORT} ${VHOST_ALIAS}

