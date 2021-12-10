param accountName string
param location string
param containerNames array

param adfPrincipalId string

param vnetId string = ''
param skuName string = 'Standard_LRS'

param deploymentTime string

var vnetIntegrate = !empty(vnetId)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
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

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: '${accountName}/default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = [for c in containerNames: {
  name: '${accountName}/default/${c}'
}]

module roles 'roles.bicep' = {
  name: 'roles-${deploymentTime}'
}

resource rbacAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid('rbac-${storageAccount.name}')
  scope: storageAccount
  properties: {
    roleDefinitionId: roles.outputs.roles['Storage Blob Data Contributor']
    principalId: adfPrincipalId
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
