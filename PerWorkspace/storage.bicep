param workspaceResourceNameSuffix string
param location string
param deploymentTime string
param vnetId string

var workspaceResourceNameSuffixClean = replace(workspaceResourceNameSuffix, '-', '')
module publicStorageAccount 'storage_shared.bicep' = {
  name: 'stg-public-${deploymentTime}'
  params: {
    accountName: 'stgpub${workspaceResourceNameSuffixClean}'
    location: location
  }
}

module privateStorageAccount 'storage_shared.bicep' = {
  name: 'stg-private-${deploymentTime}'
  params: {
    accountName: 'stgpri${workspaceResourceNameSuffixClean}'
    location: location
    // The private storage account must be integrated with a VNet
    vnetId: vnetId
  }
}

module eventGridForPublic 'eventGrid_shared.bicep' = {
  name: 'evgt-public-${deploymentTime}'
  params: {
    location: location
    storageAccountName: publicStorageAccount.outputs.storageAccountName
    workspaceResourceNameSuffix: workspaceResourceNameSuffix
  }
}

// TODO: Create default container names?

module eventGridForPrivate 'eventGrid_shared.bicep' = {
  name: 'evgt-private-${deploymentTime}'
  params: {
    location: location
    storageAccountName: privateStorageAccount.outputs.storageAccountName
    workspaceResourceNameSuffix: workspaceResourceNameSuffix
  }
}

output publicStorageAccountId string = publicStorageAccount.outputs.storageAccountId
output privateStorageAccountId string = privateStorageAccount.outputs.storageAccountId

output publicStorageAccountName string = publicStorageAccount.outputs.storageAccountName
output privateStorageAccountName string = privateStorageAccount.outputs.storageAccountName

output publicSystemTopicName string = eventGridForPublic.outputs.systemTopicName
output privateSystemTopicName string = eventGridForPrivate.outputs.systemTopicName
