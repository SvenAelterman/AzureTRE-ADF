targetScope = 'subscription'

param azureTreId string
param location string
param workspaceId string

param deploymentTime string = utcNow()

var shortWorkspaceId = '${substring(workspaceId, length(workspaceId) - 4, 4)}'
var workspaceResourceNameSuffix = '${azureTreId}-ws-${shortWorkspaceId}'

@description('The resource ID of the workspace\'s VNet')
var vnetId = 'vnet-${workspaceResourceNameSuffix}'

var adfName = 'adf-${azureTreId}-${location}'

resource treHubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${azureTreId}'
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
  scope: treHubResourceGroup
}

resource workspaceResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${workspaceResourceNameSuffix}'
}

module storageAccounts 'storage.bicep' = {
  name: 'stg-${deploymentTime}'
  scope: workspaceResourceGroup
  params: {
    workspaceResourceNameSuffix: workspaceResourceNameSuffix
    location: location
    deploymentTime: deploymentTime
    vnetId: vnetId
    adfPrincipalId: adf.identity.principalId
  }
}

module adfTriggers 'adf.bicep' = {
  name: 'adf-ws-${shortWorkspaceId}-${deploymentTime}'
  params: {
    adfName: adfName
    // TODO: Hardcoded
    ingestPipelineName: 'pipe-data_move'
    azureTreId: azureTreId
    deploymentTime: deploymentTime
    publicStorageAccountId: storageAccounts.outputs.publicStorageAccountId
    publicStorageAccountName: storageAccounts.outputs.publicStorageAccountName
    privateStorageAccountId: storageAccounts.outputs.privateStorageAccountId
    privateStorageAccountName: storageAccounts.outputs.privateStorageAccountName
    shortWorkspaceId: shortWorkspaceId
  }
}

module eventGridSubscriptions 'eventGridSubscriptions.bicep' = {
  name: 'evgs-${deploymentTime}'
  scope: workspaceResourceGroup
  params: {
    workspaceResourceNameSuffix: workspaceResourceNameSuffix
    publicStorageAccountId: storageAccounts.outputs.publicStorageAccountId
  }
}
