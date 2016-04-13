#!/bin/bash
USER_NAME=$1
APW=$2
ORG_NAME=$3
ENV_NAME=$4
VHOST_NAME=$5
VHOST_PORT=$6
VHOST_ALIAS=$7

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${MYDIR}/apigee-env.sh
. ${MYDIR}/apigee-lib.sh

if [ -z "$MSIP" ]; then
  echo "No MSIP (management server ip-address/fqdn) found in"
  echo "${BIN_DIR}/apigee-env.sh."
  echo "Run this script after running apigee-setup.sh."
  exit 1
fi

echo
echo "This script will create an organization with an organization admin,"
echo "enable role based access control and create environments."
if [ ${HAS_AX} -eq 1 ]; then
	echo "Additionally it allows to enable Analytics for the created organization"
fi
echo

[ ms_reachable ] && [ -z "${APW}" ] && enter_APW

echo; echo
echo "Create User"
echo  "-----------"

NEW_USER=n
#NEW_USER=`get_input "Create a new user y/n" type="y/n"  default="y"`
if [ ${NEW_USER} == "y" ]; then
	. ${MYDIR}/create-user.sh
else
	USER_NAME=${USER_NAME}
	#USER_NAME=`get_input "Enter email of user to be organization admin" mand="y"`
fi

echo; echo
echo "Next: Create Organization"
echo "-------------------------"

#read -n 1 -p  "(press any key)" KEY
. ${MYDIR}/create-org.sh -a "${USER_NAME}" -P "${APW}" -o "${ORG_NAME}"

echo; echo
echo "Next: Create Access Roles"
echo "-------------------------"

#read -n 1 -p  "(press any key)" KEY
. ${MYDIR}/create-roles.sh -o ${ORG_NAME} -P "${APW}"

echo; echo
echo "Next: Create Environments"
echo "-------------------------"

#read -n 1 -p  "(press any key)" KEY
NEW_ENV="y"
while [ ${NEW_ENV} == "y" ]; do
	#ENV_NAME=""
	#VHOST_PORT=""
	#VHOST_NAME=""
	#VHOST_ALIAS=""
	. ${MYDIR}/add-env.sh -o ${ORG_NAME} -P "${APW}" -A -e "${ENV_NAME}" -v "${VHOST_NAME}" -p ${VHOST_PORT} -a "${VHOST_ALIAS}"
	echo; echo
	NEW_ENV="n"
	#NEW_ENV=`get_input "Add another environment y/n" type="y/n"  default="y"`
done

