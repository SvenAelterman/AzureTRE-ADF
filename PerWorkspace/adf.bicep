targetScope = 'subscription'

param azureTreId string
param adfName string
param ingestPipelineName string
param publicStorageAccountId string
param publicStorageAccountName string
param privateStorageAccountId string
param privateStorageAccountName string
param deploymentTime string
param shortWorkspaceId string

resource treHubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${azureTreId}'
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
  scope: treHubResourceGroup
}

module containerNames 'containerNames.bicep' = {
  name: 'cn'
  scope: treHubResourceGroup
}

module ingestTrigger 'adfTrigger_shared.bicep' = {
  scope: treHubResourceGroup
  name: 'adf-trigger-public-${deploymentTime}'
  params: {
    adfName: adf.name
    storageAccountId: publicStorageAccountId
    shortWorkspaceId: shortWorkspaceId
    storageAccountType: 'Public'
    ingestPipelineName: ingestPipelineName
    sourceStorageAccountName: publicStorageAccountName
    sinkStorageAccountName: privateStorageAccountName
    containerName: containerNames.outputs.ingestContainerName
  }
}

module exportTrigger 'adfTrigger_shared.bicep' = {
  scope: treHubResourceGroup
  name: 'adf-trigger-private-${deploymentTime}'
  params: {
    adfName: adf.name
    storageAccountId: privateStorageAccountId
    shortWorkspaceId: shortWorkspaceId
    storageAccountType: 'Private'
    ingestPipelineName: ingestPipelineName
    sourceStorageAccountName: privateStorageAccountName
    sinkStorageAccountName: publicStorageAccountName
    containerName: containerNames.outputs.exportApprovedContainerName
  }
}

module adfManagedPrivateEndpoint 'adfManagedPrivateEndpoint.bicep' = {
  name: 'adf-pe-${deploymentTime}'
  scope: treHubResourceGroup
  params: {
    adfName: adfName
    privateStorageAccountId: privateStorageAccountId
    privateStorageAccountName: privateStorageAccountName
  }
}
