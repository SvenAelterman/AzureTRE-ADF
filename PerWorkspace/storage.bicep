param azureTreId string
param location string
param deploymentTime string
param vnetId string

module publicStorageAccount 'storage_shared.bicep' = {
  name: 'st-public-${deploymentTime}'
  params: {
    accountName: 'stin${azureTreId}'
    location: location
  }
}

module privateStorageAccount 'storage_shared.bicep' = {
  name: 'st-private-${deploymentTime}'
  params: {
    accountName: 'stout${azureTreId}'
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
    azureTreId: azureTreId
  }
}

module eventGridForPrivate 'eventGrid_shared.bicep' = {
  name: 'evgt-private-${deploymentTime}'
  params: {
    location: location
    storageAccountName: privateStorageAccount.outputs.storageAccountName
    azureTreId: azureTreId
  }
}

output publicStorageAccountId string = publicStorageAccount.outputs.storageAccountId
output privateStorageAccountId string = privateStorageAccount.outputs.storageAccountId
