mkdir -p solutions-template
cd solutions-template
cp -fr ../azuredeploy.json mainTemplate.json
cp -fr ../azuredeploy.parameters.json mainTemplate.parameters.json
cp -fr ../templates/createUiDefinition.json .
cp -fr ../templates/analytics-instances.json .
cp -fr ../templates/empty-resources.json .
cp -fr ../templates/internal-instances.json .
cp -fr ../templates/shared-resources.json .
cp -fr ../templates/install-apigee.sh .
cp -fr ../templates/install-portal.sh .
cp -fr ../templates/management-instances-password.json .
cp -fr ../templates/management-instances-sshPublicKey.json .
cp -fr ../templates/devportal-instances-password.json .
cp -fr ../templates/devportal-instances-sshPublicKey.json .
cp -fr ../templates/rmp-instances.json .
cp -fr ../metadata.json .
cp -fr ../README.md .
cd ..
rm -fr solutions-template.zip
zip -rj solutions-template.zip solutions-template
rm -fr solutions-template
