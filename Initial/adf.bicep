param name string
param location string

var managedVnetName = 'default'
var autoResolveIntegrationRuntimeName = 'AutoResolveIntegrationRuntime'

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
  name: '${name}/${autoResolveIntegrationRuntimeName}'
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

resource genericLinkedServiceAdlsGen2 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${name}/ls_ADLSGen2_Generic'
  dependsOn: [
    adf
    integrationRuntime
  ]
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: '@{concat(\'https://\', linkedService().storageAccountName, \'.dfs.${environment().suffixes.storage}\')}'
    }
    connectVia: {
      referenceName: autoResolveIntegrationRuntimeName
      type: 'IntegrationRuntimeReference'
    }
    parameters: {
      storageAccountName: {
        type: 'String'
      }
    }
  }
}

// TODO: Add pipelines
