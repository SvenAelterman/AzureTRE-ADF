param location string
//param storageAccountId string
param storageAccountName string
param azureTreId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource eventGridSystemTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: 'evgt-${storageAccountName}-${azureTreId}'
  location: location
  dependsOn: [
    storageAccount
  ]
  properties: {
    source: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}
