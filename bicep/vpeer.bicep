param vnethubname string
param vnetspokename string
param spokeUseRemoteGateways bool = true

resource vnethub 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnethubname
}

resource vnetspoke 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetspokename
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
