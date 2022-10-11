targetScope='resourceGroup'

param prefix string
param haspubip bool = false
param vnetname string
param location string
@secure()
param password string
param username string
param myObjectId string
param postfix string = ''
param privateip string
param isipff bool = false
param customData string = ''
@allowed([
  'windows'
  'linux'
  'nodejs'
  'winserver'
  'cisco'
])
param imageRef string

var imageReferences = {
  linux: {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18.04-LTS'
    version: 'latest'
  }
  winserver: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-datacenter-gensecond'
    version: 'latest'
  }
  windows: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: '20h2-pro'
    version: 'latest'
  }
  nodejs: {
    publisher: 'bitnami'
    offer: 'nodejs'
    sku: '4-3'
    version: 'latest'
  }
  cisco: {
    publisher: 'cisco'
    offer: 'cisco-csr-1000v'
    sku: '17_2_1-byol'
    version: '17.2.120200508'
  }
}

var linconfig= {
  linux: {
    disablePasswordAuthentication: false
    ssh: {
      publicKeys: [
        {
          path:'/home/chpinoto/.ssh/authorized_keys'
          keyData: sshkey.properties.publicKey
        }
      ]
    }
  }
  cisco: {
    disablePasswordAuthentication: false
    ssh: {
      publicKeys: [
        {
          path:'/home/chpinoto/.ssh/authorized_keys'
          keyData: sshkey.properties.publicKey
        }
      ]
    }
  }
  windows: null
  nodejs: null
  winserver: null
}

var plan={
  nodejs:{
    name:'4-3'
    publisher:'bitnami'
    product:'nodejs'
  }
  cisco:{
    name:'17_2_1-byol'
    publisher:'cisco'
    product:'cisco-csr-1000v'
  }
  windows: null
  linux: null
  winserver: null
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' existing = {
  name: vnetname
}

resource pubip 'Microsoft.Network/publicIPAddresses@2021-03-01' = if (haspubip) {
  name: '${prefix}${postfix}'
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod:'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${prefix}${postfix}'
        properties: {
          publicIPAddress : haspubip ? {
            id: pubip.id
          } : null
          privateIPAddress:privateip
          // privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${vnet.id}/subnets/${prefix}'
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: isipff ? true : false
  }
}

resource sshkey 'Microsoft.Compute/sshPublicKeys@2021-07-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    publicKey: loadTextContent('../ssh/chpinoto.pub')
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${prefix}${postfix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  plan: plan[imageRef]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      osDisk: {
        name: '${prefix}${postfix}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption:'Delete'
      }
      imageReference: imageReferences[imageRef]
    }
    osProfile: {
      computerName: '${prefix}${postfix}'
      adminUsername: username
      adminPassword: password
      //customData: loadFileAsBase64('vm.yaml')
      customData: !empty(customData) ? base64(customData) : null
      linuxConfiguration: linconfig[imageRef]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties:{
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

resource vmaadextension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (imageRef!='windows' && imageRef!='winserver' && imageRef!='cisco') {
  parent: vm
  name: 'AADSSHLoginForLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
  }
}

resource nwagentextension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (imageRef!='windows' && imageRef!='winserver' && imageRef!='cisco') {
  parent: vm
  name: 'NetworkWatcherAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentLinux'
    typeHandlerVersion: '1.4'
  }
}

var roleVirtualMachineAdministratorName = '1c0163c0-47e6-4577-8991-ea5c82e286e4' //Virtual Machine Administrator Login

resource raMe2VM 'Microsoft.Authorization/roleAssignments@2018-01-01-preview' = {
  name: guid(resourceGroup().id,'raMe2VMHub')
  properties: {
    principalId: myObjectId
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions',roleVirtualMachineAdministratorName)
  }
}

@description('VNet Name')
output pubip string = haspubip ? pubip.properties.ipAddress : ''



