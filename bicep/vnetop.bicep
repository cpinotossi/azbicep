targetScope = 'resourceGroup'

param postfix string
param prefix string
param location string
param cidervnet string
param cidersubnet string
param ciderbastion string
param srcip string
param desip string
param descider string
param gwip string


resource vnethub 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    subnets: [
      {
        name: prefix
        properties: {
          addressPrefix: cidersubnet
          serviceEndpoints:[
            {
              locations:[
                location
              ]
              service:'Microsoft.Storage'
            }
          ]
          networkSecurityGroup:{
            id: nsg.id
          }
          routeTable:{
            id: rt.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: ciderbastion
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
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

resource pubipbastion 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${prefix}${postfix}bastion'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod:'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-03-01' = {
  name: '${prefix}${postfix}'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    dnsName:'${prefix}${postfix}.bastion.azure.com'
    enableTunneling: true
    ipConfigurations: [
      {
        name: '${prefix}${postfix}bastion'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pubipbastion.id
          }
          subnet: {
            id: '${vnethub.id}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh' // maybe not needed can be done via bastion
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: srcip
          destinationAddressPrefix: desip
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'op2az'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: cidervnet
          destinationAddressPrefix: descider
          access: 'Allow'
          priority: 110
          direction: 'outbound'
        }
      }
      {
        name: 'az2op'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: descider
          destinationAddressPrefix: cidervnet
          access: 'Allow'
          priority: 110
          direction: 'inbound'
        }
      }
    ]
  }
}

resource rt 'Microsoft.Network/routeTables@2022-01-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties:{
    disableBgpRoutePropagation: true
    routes:[
      {
        name:'${prefix}${postfix}'
        properties:{
          nextHopType: 'VirtualAppliance'
          addressPrefix: descider // target ip ragne
          nextHopIpAddress: gwip
          hasBgpOverride: false
        }
      }
    ]
  }
}

@description('VNet Name')
output vnetname string = vnethub.name
