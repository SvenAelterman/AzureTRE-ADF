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
param exportApprovedContainerName string = 'export-approved'

resource treHubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${azureTreId}'
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
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
  }
}

module exportTrigger 'adfTrigger_shared.bicep' = {
  scope: treHubResourceGroup
  name: 'adf-trigger-public-${deploymentTime}'
  params: {
    adfName: adf.name
    storageAccountId: privateStorageAccountId
    shortWorkspaceId: shortWorkspaceId
    storageAccountType: 'Private'
    ingestPipelineName: ingestPipelineName
    sourceStorageAccountName: privateStorageAccountName
    sinkStorageAccountName: publicStorageAccountName
    containerName: exportApprovedContainerName
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
