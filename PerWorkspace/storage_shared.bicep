param accountName string
param location string

param vnetId string = ''

var vnetIntegrate = !empty(vnetId)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    isHnsEnabled: true
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    networkAcls: vnetIntegrate ? {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      // TODO: Allow access from workspace's VNet, or only use private endpoints?
      virtualNetworkRules: []
    } : json('null')
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
