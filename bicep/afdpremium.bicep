param prefix string
param originhost string
param plsvclocation string = 'eastus'

resource plsvc 'Microsoft.Network/privateLinkServices@2022-05-01' existing = {
  name: prefix
}

resource dnszones 'Microsoft.Network/dnszones@2018-05-01' existing = {
  name: prefix
}

resource afdprofile 'Microsoft.Cdn/profiles@2022-05-01-preview' = {
  name: prefix
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
    extendedProperties: {
    }
  }
}

resource afdendpoint 'Microsoft.Cdn/profiles/afdendpoints@2022-05-01-preview' = {
  parent: afdprofile
  name: prefix
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource afdorigingrp 'Microsoft.Cdn/profiles/origingroups@2022-05-01-preview' = {
  parent: afdprofile
  name: prefix
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

// resource afdprofilesecret 'Microsoft.Cdn/profiles/secrets@2022-05-01-preview' = {
//   parent: afdprofile
//   // name: '20e684e8-08cb-437a-aff5-53d4098e97fb-www-${prefix}-org'
//   name: '${guid(prefix)}-www-${prefix}-org'
//   properties: {
//     parameters: {
//       type: 'ManagedCertificate'
//     }
//   }
// }

resource afdafdorigin 'Microsoft.Cdn/profiles/origingroups/origins@2022-05-01-preview' = {
  parent: afdorigingrp
  name: prefix
  properties: {
    hostName: plsvc.properties.ipConfigurations[0].properties.privateIPAddress
    httpPort: 80
    httpsPort: 443
    originHostHeader: originhost
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    sharedPrivateLinkResource: {
      privateLink: {
        id: plsvc.id
      }
      privateLinkLocation: plsvclocation
      requestMessage: prefix
    }
    enforceCertificateNameCheck: true
  }
}

resource afdcustomdomain 'Microsoft.Cdn/profiles/customdomains@2022-05-01-preview' = {
  parent: afdprofile
  name: 'www-${prefix}-org'
  properties: {
    hostName: 'www.${prefix}.org'
    // tlsSettings: {
    //   certificateType: 'ManagedCertificate'
    //   minimumTlsVersion: 'TLS12'
    //   secret: {
    //     id: afdprofilesecret.id
    //   }
    // }
    azureDnsZone: {
      id: dnszones.id
    }
  }
}

resource afdroutes 'Microsoft.Cdn/profiles/afdendpoints/routes@2022-05-01-preview' = {
  parent: afdendpoint
  name: prefix
  properties: {
    customDomains: [
      {
        id: afdcustomdomain.id
      }
    ]
    originGroup: {
      id: afdorigingrp.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Disabled'
    enabledState: 'Enabled'
  }
}

output fqdn string = afdendpoint.properties.hostName



