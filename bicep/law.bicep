targetScope='resourceGroup'

param prefix string
param postfix string = ''
param location string

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${prefix}${postfix}'
  location: location
  properties: {
    sku:{
      name: 'PerGB2018'
    }
    retentionInDays:30
  }
}
