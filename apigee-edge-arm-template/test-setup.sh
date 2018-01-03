group=$1
deployment=$2
azure group create $group -l "centralus"
azure group deployment create $group $deployment -f azuredeploy.json -e azuredeploy.parameters.json  
