param prefix string
param postfix string = ''
param location string
param feip string
param beport int = 80
param feport int = 80

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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: feip
          subnet: {
            // id: vnet.properties.subnets[1].id
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', prefix, prefix)
          }
          privateIPAddressVersion: 'IPv4'
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
              }
            }
          ]
        }
      }
    ]
    loadBalancingRules: [
      {
        name: prefix
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/loadBalancers', prefix)}/frontendIPConfigurations/${prefix}${postfix}'
          }
          frontendPort: feport
          backendPort: beport
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: false
          loadDistribution: 'Default'
          disableOutboundSnat: true
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/loadBalancers', prefix)}/backendAddressPools/${prefix}${postfix}'
          }
          probe: {
            id: '${resourceId('Microsoft.Network/loadBalancers', prefix)}/probes/${prefix}${postfix}'
          }
        }
      }
    ]
    probes: [
      {
        name: prefix
        properties: {
          protocol: 'Http'
          port: 9000
          requestPath: '/index.html'
          intervalInSeconds: 5
          numberOfProbes: 1
        }
      }
    ]
    inboundNatRules: []
    outboundRules: []
    inboundNatPools: []
  }
}

@description('lb id')
output id string = lb.id
@description('lb frontend ip id')
output fipid string = lb.properties.frontendIPConfigurations[0].id

