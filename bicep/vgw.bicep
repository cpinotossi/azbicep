param prefix string
param postfix string
param location string
param vnetname string
param vnetopname string
param bgpip string

@description('Public IP of your StrongSwan Instance')
param localGatewayIpAddress string = '1.1.1.1'

@description('Shared key (PSK) for IPSec tunnel')
@secure()
param sharedKey string = 'demo!pass123'

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetname
}

resource vnetop 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetopname
}

resource lgw 'Microsoft.Network/localNetworkGateways@2020-08-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: vnetop.properties.addressSpace.addressPrefixes
    }
    gatewayIpAddress: localGatewayIpAddress
    bgpSettings:{
      asn: 65001
      bgpPeeringAddress: '192.168.1.1' //like defined inside the cisco configuration
    }
  }
}

resource gatewayconnection 'Microsoft.Network/connections@2020-07-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: vgw.id
      properties:{}
    }
    localNetworkGateway2: {
      id: lgw.id
      properties:{}
    }
    connectionType: 'IPsec'
    routingWeight: 10
    sharedKey: sharedKey
    enableBgp: true
  }
}

resource pubipvgw 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${prefix}${postfix}'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod:'Static'
  }
}

resource vgw 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    sku: {
      name:'VpnGw2'
      tier:'VpnGw2'
    }
    gatewayType:'Vpn'
    vpnType:'RouteBased'
    enableBgp: true
    activeActive: false
    ipConfigurations: [
      {
        name: '${prefix}${postfix}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pubipvgw.id
          }
          subnet: {
            id: '${vnet.id}/subnets/GatewaySubnet'
          }
        }
      }
    ]
    // vpnClientConfiguration: {
    //   vpnClientAddressPool:{
    //     addressPrefixes:[
    //       '172.16.25.0/24'
    //     ]
    //   }
    //   vpnClientProtocols:[
    //     'SSTP'
    //     'IkeV2'
    //   ]
    //   vpnClientRootCertificates: [
    //     {
    //       name: '${prefix}win'
    //       properties: {
    //         publicCertData: 'MIIC4TCCAcmgAwIBAgIQEZ1/NZ4RUKBL5KFiE5EwtTANBgkqhkiG9w0BAQsFADAT MREwDwYDVQQDDAhjcHRkdm5ldDAeFw0yMjAxMjgxOTM3NDdaFw0yMzAxMjgxOTU3 NDdaMBMxETAPBgNVBAMMCGNwdGR2bmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A MIIBCgKCAQEAtiCgS4WSe9/eKROUMCkGuoQmVgGWNYHdkOeOrGybBKCxtJEsx/zi 4cuBSHSUZvqtaC17B0HuYfDNqTH5oxxGXKZpSuCeilCDIUAoQ5DDR0fVzinPJuDB H0oh8ZaAMa6CvtmjNM22Hhhgn3RM0LH7+TsxUa4oVX8nisrlQjoU/9q75lL1rDBQ g7Obj0XdZ3/BzRfLEN1wS+jV9IMBiit8mOUluwRElxHfUQIKtxSMtsAy4N3wiMOf 4TGUsqj/23ZbZJ6ONm8+LuM6vlurGemXHSawyEFtXvk7/O2evt5RCEePovwe53lV fx/s7mTGvZqVSW2bZD0Zn8umY9JaNqdqDQIDAQABozEwLzAOBgNVHQ8BAf8EBAMC AgQwHQYDVR0OBBYEFMrBHEauinQEZ6AT3liH9utbc2+iMA0GCSqGSIb3DQEBCwUA A4IBAQB8NFA5UwaJ2RIYcjkk2zxpNgBczLUrCMOoBGid66xszn9/CLebK2GNayuY BBz9GH6Aa4YUgfNDHcUI4BUkTAMwqrEL9CcE1zuxUksR4Hfe36VikZk1m5L2eEN0 DlpSZPGwDGXLi1/o+Q4+8Lj7JtdoDLEePjsH6VEXXAUb8NNzd91hYG2je8jObMkE bzMaKQHj5340XAA1tev0XHr8XyZb0iXHQKQ0NDgikN2GvBAv/tmO77qhgul9By7u ZPDTiozJ4ND6IQ41SiMP/3Xa0f8XlWzNTa8pZFqa5UJTtiPQ5tQvZ3x3UCXTjy1R f66nAh60AWZAAHmJ3ZdX/nRRvZZk'
    //       }
    //     }
    //   ]
    // }
  }
}
