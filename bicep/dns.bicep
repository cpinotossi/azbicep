param prefix string
param tld string = 'org'

resource dnszone 'Microsoft.Network/dnszones@2018-05-01' = {
  name: '${prefix}.${tld}'
  location: 'global'
  properties: {
    zoneType: 'Public'
  }
  tags:{
    env: prefix
  }
}

resource dnszonewwwverify 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  parent: dnszone
  name: 'afdverify.www'
  properties: {
    TTL: 10
    CNAMERecord: {
      cname: 'afdverify.${prefix}.azurefd.net'
    }
    targetResource: {}
  }
}

resource dnszonewww 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  parent: dnszone
  name: 'www'
  properties: {
    TTL: 10
    CNAMERecord: {
      cname: '${prefix}.azurefd.net'
    }
    targetResource: {}
  }
}
// resource dnszonered 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
//   parent: dnszone
//   name: 'afdverify.cptdafdred'
//   properties: {
//     TTL: 10
//     CNAMERecord: {
//       cname: 'afdverify.cptdafd.azurefd.net'
//     }
//     targetResource: {}
//   }
// }

// resource dnszonewildcard 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
//   parent: dnszone
//   name: 'afdverify'
//   properties: {
//     TTL: 10
//     CNAMERecord: {
//       cname: 'afdverify.cptdafd.azurefd.net'
//     }
//     targetResource: {}
//   }
// }

// resource dnszonens 'Microsoft.Network/dnszones/NS@2018-05-01' = {
//   parent: dnszone
//   name: '@'
//   properties: {
//     TTL: 172800
//     NSRecords: [
//       {
//         nsdname: 'ns1-09.azure-dns.com.'
//       }
//       {
//         nsdname: 'ns2-09.azure-dns.net.'
//       }
//       {
//         nsdname: 'ns3-09.azure-dns.org.'
//       }
//       {
//         nsdname: 'ns4-09.azure-dns.info.'
//       }
//     ]
//     targetResource: {}
//   }
// }

// resource dnszonesoa 'Microsoft.Network/dnszones/SOA@2018-05-01' = {
//   parent: dnszone
//   name: '@'
//   properties: {
//     TTL: 3600
//     SOARecord: {
//       email: 'azuredns-hostmaster.microsoft.com'
//       expireTime: 2419200
//       host: 'ns1-09.azure-dns.com.'
//       minimumTTL: 300
//       refreshTime: 3600
//       retryTime: 300
//       serialNumber: 1
//     }
//     targetResource: {}
//   }
// }
