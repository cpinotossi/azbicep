@description('Set the local VNet name')
param sourcevnetname string

@description('Set the remote VNet name')
param targetvnetname string

@description('Sets the remote VNet Resource group')
param targetrgname string

resource targetvnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: targetvnetname
  scope: resourceGroup(targetrgname)
}

resource sourcevnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: sourcevnetname
}

resource existingLocalVirtualNetworkName_peering_to_remote_vnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${sourcevnetname}/${sourcevnetname}-${targetvnetname}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: targetvnet.id
    }
  }
}
