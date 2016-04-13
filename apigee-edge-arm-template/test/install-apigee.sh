echo 'executing the install script' >>/tmp/armscript.log

USER_NAME=$1
APW=$2
ORG_NAME=$3
VHOST_ALIAS=$4
ENV_NAME='test'
VHOST_NAME='default'
VHOST_PORT='9002'
EDGE_VERSION='4.15.07.03'

echo 'script execution started at:'>>/tmp/armscript.log
echo $(date)>>/tmp/armscript.log
echo 'Inititalized variables, ' $VHOST_ALIAS, $EDGE_VERSION >>/tmp/armscript.log


cd /tmp/apigee

echo 'in tmp folder' >> /tmp/armscript.log

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

