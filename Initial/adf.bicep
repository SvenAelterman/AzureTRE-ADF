param name string
param location string

var managedVnetName = 'default'
var autoResolveIntegrationRuntimeName = 'AutoResolveIntegrationRuntime'
var linkedServiceName = 'ls_ADLSGen2_Generic'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
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
  name: '${name}/${linkedServiceName}'
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

resource dfsDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${name}/DfsDataset'
  properties: {
    type: 'Binary'
    linkedServiceName: {
      referenceName: linkedServiceName
      type: 'LinkedServiceReference'
      parameters: {
        storageAccountName: {
          value: '@dataset().storageAccountName'
          type: 'Expression'
        }
      }
    }
    parameters: {
      storageAccountName: {
        type: 'String'
      }
      folderPath: {
        type: 'String'
      }
      fileName: {
        type: 'String'
      }
    }
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@dataset().fileName'
          type: 'Expression'
        }
        fileSystem: {
          value: '@dataset().folderPath'
          type: 'Expression'
        }
      }
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${name}/pipe-data_move'
  properties: {
    activities: [
      json(loadTextContent('./Content/adfPipeline.json'))
    ]
    parameters: {
      sourceStorageAccountName: {
        type: 'String'
      }
      sinkStorageAccountName: {
        type: 'String'
      }
      folderPath: {
        type: 'String'
      }
      fileName: {
        type: 'String'
      }
    }
  }
}
