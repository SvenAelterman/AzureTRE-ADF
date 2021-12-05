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
  }
}

module adfTriggers 'adfTriggers.bicep' = {
  name: 'adf-trigger-${deploymentTime}'
  params: {
    adfName: adfName
    // TODO: Hardcoded
    ingestPipelineName: 'pipe-pub_to_pri'
    azureTreId: azureTreId
    deploymentTime: deploymentTime
    publicStorageAccountId: storageAccounts.outputs.publicStorageAccountId
    publicStorageAccountName: storageAccounts.outputs.publicStorageAccountName
    shortWorkspaceId: shortWorkspaceId
  }
}

// TODO: Managed Private Endpoint in ADF for private storage account

module eventGridSubscriptions 'eventGridSubscriptions.bicep' = {
  name: 'evgs-${deploymentTime}'
  scope: workspaceResourceGroup
  params: {
    workspaceResourceNameSuffix: workspaceResourceNameSuffix
    publicStorageAccountId: storageAccounts.outputs.publicStorageAccountId
  }
}
