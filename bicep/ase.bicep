param prefix string
param location string
param subscriptionId string
param dedicatedHostCount string
param zoneRedundant bool
param virtualNetworkName string
param virtualNetworkResourceGroupName string
param virtualNetworkAddress string
param subnetName string
param subnetId string
param subnetAddress string
param delegationName string
param hostingEnvironmentId string
param ilbMode int
param subnet object

module updateExistingSubnetTemplate './nested_updateExistingSubnetTemplate.bicep' = {
  name: 'updateExistingSubnetTemplate'
  scope: resourceGroup(subscriptionId, virtualNetworkResourceGroupName)
  params: {
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    subnet: subnet
  }
}

resource aseName_resource 'Microsoft.Web/hostingEnvironments@2019-08-01' = {
  name: prefix
  location: location
  tags: {
  }
  kind: 'ASEV3'
  properties: {
    name: prefix
    location: location
    internalLoadBalancingMode: 'Web'
    workerPools:[
      {
        
      }
    ]
    virtualNetwork: {
      id: subnetId
    }
  }
  dependsOn: [
    updateExistingSubnetTemplate
  ]
}
