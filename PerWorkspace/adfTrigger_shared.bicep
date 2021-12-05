param storageAccountId string
param sinkStorageAccountName string
param sourceStorageAccountName string
param adfName string
param ingestPipelineName string
param shortWorkspaceId string
@allowed([
  'Public'
  'Private'
])
param storageAccountType string

resource publicTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: '${adfName}/trigger_ws_${shortWorkspaceId}_${storageAccountType}_BlobCreated'
  properties: {
    type: 'BlobEventsTrigger'
    typeProperties: {
      // No blobPathBeginsWith property means all containers will be matched
      ignoreEmptyBlobs: true
      events: [
        'Microsoft.Storage.BlobCreated'
      ]
      scope: storageAccountId
    }
    pipelines: [
      {
        pipelineReference: {
          referenceName: ingestPipelineName
          type: 'PipelineReference'
        }
        parameters: {
          sourceStorageAccountName: sourceStorageAccountName
          sinkStorageAccountName: sinkStorageAccountName
          fileName: '@triggerBody().fileName'
          folderPath: '@triggerBody().folderPath'
        }
      }
    ]
  }
}
