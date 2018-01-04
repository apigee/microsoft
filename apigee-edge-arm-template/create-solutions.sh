mkdir -p solutions-template
cd solutions-template
cp -fr ../azuredeploy.json mainTemplate.json
cp -fr ../azuredeploy.parameters.json mainTemplate.parameters.json
cp -fr ../createUiDefinition.json .
cp -fr ../analytics-instances.json .
cp -fr ../empty-resources.json .
cp -fr ../install-apigee.sh .
cp -fr ../internal-instances.json .
cp -fr ../management-instances-password.json .
cp -fr ../management-instances-sshPublicKey.json .
cp -fr ../rmp-instances.json .
cp -fr ../shared-resources.json .
cp -fr ../metadata.json .
cp -fr ../README.md .
cd ..
rm -fr solutions-template.zip
zip -rj solutions-template.zip solutions-template
rm -fr solutions-template
