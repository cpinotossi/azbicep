targetScope='resourceGroup'

param prefix string
param postfix string
param locationvwan string
param locationvhub string
param ciderhub string

resource vwan 'Microsoft.Network/virtualWans@2021-05-01' = {
  name: prefix
  location: locationvwan
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    disableVpnEncryption: false
    type: 'Standard'
  }
}

resource vwanhub 'Microsoft.Network/virtualHubs@2021-05-01' ={
  name: '${prefix}${postfix}'
  location: locationvhub
  properties: {
    addressPrefix: ciderhub
    virtualWan: {
      id: vwan.id
    }
  }
}

@description('vwan Hub Name')
output vwanhubname string = vwanhub.name

@description('vwan Name')
output vwanname string = vwan.name
