param prefix string
param location string
param vnetname string
param saname string
param plname string

resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: saname
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetname
}

resource pe 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: plname
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${plname}${saname}'
        properties: {
          privateLinkServiceId: sa.id
          groupIds: [
            'blob'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: '${vnet.id}/subnets/${prefix}'
    }
    customDnsConfigs: []
  }
}

