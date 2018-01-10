#e.g ./clean-apigee.sh apigee2 apigee1node apigeeedgetrail2 /Qs9dg9hX1CmHcH9ri+WK1eoueh/VqxHDuDTV0WvqzfaoiR6TotzxRuy4CpjKu0HUikqrtGJ/K0/nBJiFNFCrg==
group=$1
artifact=$2
storage=$3
access_key=$4
export AZURE_STORAGE_ACCOUNT=$storage
export AZURE_STORAGE_ACCESS_KEY=$access_key

azure vm stop -g $group ${artifact}rmp0 
azure vm stop -g $group ${artifact}rmp1
azure vm stop -g $group ${artifact}management0
azure vm stop -g $group ${artifact}analytics0
azure vm stop -g $group ${artifact}analytics1
azure vm stop -g $group ${artifact}datastore0
azure vm stop -g $group ${artifact}datastore1
azure vm stop -g $group ${artifact}qpid0
azure vm stop -g $group ${artifact}qpid1
azure vm delete -g $group ${artifact}rmp0 -q 
azure vm delete -g $group ${artifact}rmp0 -q 
azure vm delete -g $group ${artifact}rmp1 -q
azure vm delete -g $group ${artifact}management0 -q
azure vm delete -g $group ${artifact}analytics0 -q
azure vm delete -g $group ${artifact}analytics1 -q
azure vm delete -g $group ${artifact}datastore0 -q
azure vm delete -g $group ${artifact}datastore1 -q
azure vm delete -g $group ${artifact}qpid0 -q
azure vm delete -g $group ${artifact}qpid1 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}rmp0 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}rmp1 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}management0 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}analytics0 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}analytics1 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}datastore0 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}datastore1 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}qpid0 -q
azure network nic delete -g $group ApigeeVMNic-${artifact}qpid1 -q
azure network lb delete -g $group ApigeeLB-${artifact} -q
azure availset delete -g $group -g $group ApigeeRMPSet-${artifact} -q
azure network public-ip delete -g $group ApigeeManagementPublicIP-${artifact} -q
azure network public-ip delete -g $group ApigeeRuntimePublicIP-${artifact} -q
azure network vnet delete -g $group ApigeeVNET-${artifact} -q
azure network nsg delete -g $group ApigeeSecurityGroup-${artifact} -q

azure storage blob delete vhds ${artifact}analytics0-9datadisk0.vhd -q
azure storage blob delete vhds ${artifact}analytics1-9datadisk0.vhd -q
azure storage blob delete vhds ${artifact}analytics0-osdisk.vhd -q
azure storage blob delete vhds ${artifact}analytics1-osdisk.vhd -q
azure storage blob delete vhds ${artifact}rmp0-osdisk.vhd -q
azure storage blob delete vhds ${artifact}rmp1-osdisk.vhd -q
azure storage blob delete vhds ${artifact}datastore0-osdisk.vhd -q
azure storage blob delete vhds ${artifact}datastore1-osdisk.vhd -q
azure storage blob delete vhds ${artifact}qpid0-osdisk.vhd -q
azure storage blob delete vhds ${artifact}qpid1-osdisk.vhd -q
azure storage blob delete vhds ${artifact}management0-osdisk.vhd -q
