param name string
param location string

var managedVnetName = 'default'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
}

resource managedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: '${name}/${managedVnetName}'
  dependsOn: [
    adf
  ]
  properties: {}
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${name}/AutoResolveIntegrationRuntime'
  dependsOn: [
    managedVnet
    adf
  ]
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      type: 'ManagedVirtualNetworkReference'
      referenceName: managedVnetName
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
}

// TODO: Add pipelines
