targetScope='resourceGroup'

param hubname string
param spokename string

resource vwanhub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: hubname
}

resource spoke 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: spokename
}

resource defaultrt 'Microsoft.Network/virtualHubs/hubRouteTables@2021-02-01' existing = {
  name: 'defaultRouteTable'
  parent: vwanhub
}

resource hubtospoke 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-05-01' = {
  name: '${hubname}to${spokename}'
  parent: vwanhub
  properties: {
    routingConfiguration:{
      associatedRouteTable:{
        id: defaultrt.id
      }
      propagatedRouteTables:{
        labels:[
          'default'
        ]
        ids:[
          {
            id: defaultrt.id
          }
        ]
      }
      vnetRoutes:{
        staticRoutes:[]
      }
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
    remoteVirtualNetwork: {
      id: spoke.id
    }
  }
}

