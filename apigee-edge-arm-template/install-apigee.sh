USER_NAME=$1
APW=$2
ORG_NAME=$3
ENV_NAME=$4
VHOST_NAME=$5
VHOST_PORT=$6
VHOST_ALIAS=$7
EDGE_VERSION=$8

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

