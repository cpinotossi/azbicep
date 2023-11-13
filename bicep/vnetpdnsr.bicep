targetScope = 'resourceGroup'

param prefix string
param postfix string = ''
param location string
param cidervnet string
param cidersubnet string
param ciderdnsrin string = ''
param ciderdnsrout string = ''
param ciderbastion string = ''
param ciderfirewall string = ''
param dnsip string = '168.63.129.16'

var dnsrsubnetinname = 'dnsrin'
var dnsrsubnetoutname = 'dnsrout'

// This variable is needed because of:
// - https://github.com/Azure/bicep/issues/4023
// - https://stackoverflow.com/questions/52626721/subnet-azurefirewallsubnet-is-in-use-and-cannot-be-deleted 

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    // dhcpOptions:{
    //   dnsServers:[
    //     dnsip
    //   ]
    // }
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
        }
      }
      {
        name: dnsrsubnetinname
        properties: {
          addressPrefix: ciderdnsrin
          delegations:[
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                  serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: dnsrsubnetoutname
        properties: {
          addressPrefix: ciderdnsrout
          delegations:[
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                  serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: ciderbastion
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

resource pubipbastion 'Microsoft.Network/publicIPAddresses@2021-03-01'  = if (!empty(ciderbastion)) {
  name: '${prefix}${postfix}bastion'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod:'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-08-01' = if (!empty(ciderbastion)) {
  name: '${prefix}${postfix}'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    enableTunneling: true
    enableIpConnect: true
    // enableFileCopy: true
    enableShareableLink: true
    ipConfigurations: [
      {
        name: '${prefix}${postfix}bastion'
        properties: {
          publicIPAddress: {
            id: pubipbastion.id
          }
          subnet: {
            id: '${vnet.id}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }
}

@description('VNet Name')
output vnetname string = vnet.name
output vnetcidr string = vnet.properties.addressSpace.addressPrefixes[0]
output dnsrsubnetinname string = dnsrsubnetinname
output dnsrsubnetoutname string = dnsrsubnetoutname
output dnsrsubnetincidr string = ciderdnsrin
output dnsrsubnetoutcidr string = ciderdnsrout
