targetScope = 'subscription'

param azureTreId string
param location string

param deploymentTime string = utcNow()

var adfName = 'adf-${azureTreId}-${location}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${azureTreId}'
}

module adf 'adf.bicep' = {
  name: 'adf-${deploymentTime}'
  scope: rg
  params: {
    name: adfName
    location: location
  }
}
