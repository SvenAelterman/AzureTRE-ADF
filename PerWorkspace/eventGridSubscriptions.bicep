param workspaceResourceNameSuffix string
param publicStorageAccountId string
/*
resource copyPublicToPrivateSub 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  name: 'evgs-${workspaceResourceNameSuffix}-pub'
  properties: {
    destination: {
      endpointType: 
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      advancedFilters: [
        {
          values: [
            'FlushWithClose'
            'CopyBlob'
            'PutBlob'
          ]
          operatorType: 'StringContains'
          key: 'data.api'
        }
      ]
    }
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 10
      eventTimeToLiveInMinutes: 1440
    }
  }
}
*/
