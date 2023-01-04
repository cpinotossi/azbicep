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
// This variable is needed because of:
// - https://github.com/Azure/bicep/issues/4023
// - https://stackoverflow.com/questions/52626721/subnet-azurefirewallsubnet-is-in-use-and-cannot-be-deleted 

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    dhcpOptions:{
      dnsServers:[
        dnsip
      ]
    }
    subnets: [
      {
        name: prefix
        properties: {
          addressPrefix: cidersubnet
          serviceEndpoints:[
            /*{
              locations:[
                location
              ]
              service:'Microsoft.Storage'
            }*/
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

resource dnsrinsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (!empty(ciderdnsrin)){
  name: '${vnet.name}/dnsrin'
  properties: {
    addressPrefix: ciderdnsrin
  }
}

resource dnsroutsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (!empty(ciderdnsrout)){
  name: '${vnet.name}/dnsrout'
  properties: {
    addressPrefix: ciderdnsrin
  }
  dependsOn:[
    dnsrinsubnet
  ]
}

resource bastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (!empty(ciderbastion)){
  name: '${vnet.name}/AzureBastionSubnet'
  properties: {
    addressPrefix: ciderbastion //'10.0.1.0/24'
  }
  dependsOn:[
    dnsroutsubnet
  ]
}

resource firewallsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (!empty(ciderfirewall)){
  name: '${vnet.name}/AzureFirewallSubnet'
  properties: {
    addressPrefix: ciderfirewall //'10.0.1.0/24'
  }
  dependsOn:[
    bastionsubnet
  ]
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
    // enableShareableLink: true
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
