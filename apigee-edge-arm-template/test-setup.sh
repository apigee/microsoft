group=$1
az group create -n $group -l "centralus"
az group deployment create -g $group --template-file azuredeploy.json --parameters azuredeploy.parameters.json  
