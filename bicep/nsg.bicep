targetScope='resourceGroup'

param prefix string
param postfix string
param location string
param myip string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: myip
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}
