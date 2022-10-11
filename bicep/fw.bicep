targetScope='resourceGroup'

param prefix string
param postfix string = ''
param location string


resource pubip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${prefix}${postfix}'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod:'Static'
  }
}

resource policies 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: '${prefix}${postfix}'
  properties: {
    sku: {
      tier: 'Premium'
    }
    intrusionDetection: {
      mode: 'Off'
    }
  }
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: '${prefix}${postfix}'
}

resource fw 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${prefix}${postfix}'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses',pubip.name)
          }
        }
      }
    ]
    sku: {
      tier: 'Premium'
    }
    firewallPolicy: {
      id: resourceId('Microsoft.Network/firewallPolicies',policies.name)
    }
  }
}
