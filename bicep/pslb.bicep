param prefix string
param postfix string
param location string
param vmip string

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: '${prefix}${postfix}'
}

resource lb 'Microsoft.Network/loadBalancers@2022-01-01' = {
  name: '${prefix}${postfix}'
  location: location
  tags: {
    env: prefix
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: '${prefix}${postfix}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pubip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name:'${prefix}${postfix}'
        properties:{
          loadBalancerBackendAddresses:[
            {
              name: '${prefix}${postfix}'
              properties:{
                virtualNetwork:{
                  id: vnet.id
                }
                // subnet:{
                //   id: '${vnet.id}/subnets/${prefix}'
                // }
                // ipAddress: vmip
                // loadBalancerFrontendIPConfiguration:{
                //   id: '${resourceId('Microsoft.Network/loadBalancers', '${prefix}${postfix}')}/frontendIPConfigurations/${prefix}${postfix}'
                // }
              }
            }
          ]
        }
      }
    ]
    loadBalancingRules: []
    probes: []
    inboundNatRules: []
    outboundRules: [
      {
        name: '${prefix}${postfix}'
        properties: {
          allocatedOutboundPorts: 0
          protocol: 'All'
          enableTcpReset: true
          idleTimeoutInMinutes: 4
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/loadBalancers', '${prefix}${postfix}')}/backendAddressPools/${prefix}${postfix}'
            //id: bap.id
          }
          frontendIPConfigurations: [
            {
              id: '${resourceId('Microsoft.Network/loadBalancers', '${prefix}${postfix}')}/frontendIPConfigurations/${prefix}${postfix}'
            }
          ]
        }
      }
    ]
    inboundNatPools: []
  }
}

resource pubip 'Microsoft.Network/publicIPAddresses@2021-03-01'  = {
  name: '${prefix}${postfix}'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod:'Static'
  }
}
