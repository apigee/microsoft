group=$1
myVnet=$1Vnet
mySubnet=$1Subnet
myPublicIP=$1PublicIP
myNIC=$1NIC
myDeployment=$1Deployment
mySubnetAddressPrefix="10.10.5.0/24"
azure group create $group -l "centralus"
azure network vnet create $group $myVnet -l "centralus"
azure network vnet subnet create $group $myVnet $mySubnet $mySubnetAddressPrefix
azure network public-ip create $group $myPublicIP -l "centralus"
azure network nic create $group $myNIC -k $mySubnet -m $myVnet -p $myPublicIP -l "centralus"
azure network nic show $group $myNIC | grep Id | cut -d ':' -f 3 | tr -d ' '

azure group deployment create $group $myDeployment -f apigee-edge-trail-aio-profile.json

echo "Deleting your test setup"
read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	azure group delete $group
else [[ $response =~ ^([nN][oO]|[nN])$ ]]
    exit;
fi
