mkdir -p solutions-template
cd solutions-template
cp -fr ../azuredeploy.json mainTemplate.json
cp -fr ../azuredeploy.parameters.json mainTemplate.parameters.json
mkdir -p templates
cp -fr ../templates/createUiDefinition.json templates/
cp -fr ../templates/analytics-instances.json templates/
cp -fr ../templates/empty-resources.json templates/
cp -fr ../templates/internal-instances.json templates/
cp -fr ../templates/shared-resources.json templates/
cp -fr ../templates/install-apigee.sh templates/
cp -fr ../templates/install-portal.sh templates/
cp -fr ../templates/management-instances-password.json templates/
cp -fr ../templates/management-instances-sshPublicKey.json templates/
cp -fr ../templates/devportal-instances-password.json templates/
cp -fr ../templates/devportal-instances-sshPublicKey.json templates/
cp -fr ../templates/rmp-instances.json templates/
cp -fr ../metadata.json .
cp -fr ../README.md .
cd ..
rm -fr solutions-template.zip
zip -rj solutions-template.zip solutions-template
rm -fr solutions-template
