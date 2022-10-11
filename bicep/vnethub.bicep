targetScope = 'resourceGroup'

param postfix string
param prefix string
param location string
param cidervnet string
param cidersubnet string
param ciderbastion string
param ciderdnsrin string
param ciderdnsrout string
param cidergw string
param cidrop string
param opvpnip string
param srcip string
param desip string


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
      {
        name: 'dnsrin'
        properties: {
          addressPrefix: ciderdnsrin
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties:{
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
          privateEndpointNetworkPolicies:'Disabled'
          privateLinkServiceNetworkPolicies:'Enabled'
        }
      }
      {
        name: 'dnsrout'
        properties: {
          addressPrefix: ciderdnsrout
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties:{
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
          privateEndpointNetworkPolicies:'Disabled'
          privateLinkServiceNetworkPolicies:'Enabled'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: cidergw
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
        name: 'ssh'
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
        name: 'az2op'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: cidrop
          destinationAddressPrefix: cidervnet
          access: 'Allow'
          priority: 110
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
          destinationAddressPrefix: cidrop
          access: 'Allow'
          priority: 110
          direction: 'outbound'
        }
      }
    ]
  }
}

@description('VNet Name')
output vnetname string = vnethub.name
output vnetid string = vnethub.id
