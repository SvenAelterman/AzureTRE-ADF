param azureTreId string
param location string
param vnetId string

param deploymentTime string = utcNow()

var adfName = 'adf-${azureTreId}-${location}'

module storageAccounts 'storage.bicep' = {
  name: 'st-${deploymentTime}'
  params: {
    azureTreId: azureTreId
    location: location
    deploymentTime: deploymentTime
    vnetId: vnetId
  }
}
