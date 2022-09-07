targetScope = 'resourceGroup'

param prefix string
param postfix string
param location string
param cidervnet string
param cidersubnet string
param isnatgateway bool = false


resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    subnets: [
      {
        name: prefix
        properties: {
          natGateway : isnatgateway ? {
            id: nat.id
          } : null
          addressPrefix: cidersubnet
          serviceEndpoints:[
            {
              locations:[
                location
              ]
              service:'Microsoft.Storage'
            }
          ]
        }
      }
    ]
    addressSpace: {
      addressPrefixes: [
        cidervnet
      ]
    }
  }
}

resource nat 'Microsoft.Network/natGateways@2022-01-01' = if(isnatgateway) {
  name: '${prefix}${postfix}'
  location: location
  properties:{
    publicIpAddresses: [
      {
        id: pubip.id
      }
    ]
  }
}

resource pubip 'Microsoft.Network/publicIPAddresses@2022-01-01' = if(isnatgateway) {
  name: '${prefix}${postfix}nat'
}

output vnetname string = vnet.name



