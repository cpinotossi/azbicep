param vnethubname string
param vnetspokename string
param spokeUseRemoteGateways bool = true
param rghubname string
param rgspokename string

resource vnethub 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnethubname
  scope: resourceGroup(rghubname)
}

resource vnetspoke 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetspokename
  scope: resourceGroup(rgspokename)
}

resource peeringhub2spoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${vnethub.name}/${vnethub.name}${vnetspoke.name}'
  properties: {
    remoteVirtualNetwork: {
      id: vnetspoke.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

resource peeringspoke2hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${vnetspoke.name}/${vnetspoke.name}${vnethub.name}'
  properties: {
    remoteVirtualNetwork: {
      id: vnethub.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    allowGatewayTransit: true
    useRemoteGateways: spokeUseRemoteGateways
  }
}
