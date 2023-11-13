param virtualNetworkName string
param subnetName string
param subnet object

resource virtualNetworkName_subnetName 'Microsoft.Network/virtualNetworks/subnets@2018-04-01' = {
  name: '${virtualNetworkName}/${subnetName}'
  properties: subnet
}