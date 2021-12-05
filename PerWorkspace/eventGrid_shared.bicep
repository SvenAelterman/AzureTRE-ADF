param location string
param storageAccountName string
param workspaceResourceNameSuffix string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource eventGridSystemTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: 'evgt-${workspaceResourceNameSuffix}-${storageAccountName}'
  location: location
  dependsOn: [
    storageAccount
  ]
  properties: {
    source: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

output systemTopicName string = eventGridSystemTopic.name
