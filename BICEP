@description('Location for all resources')
param location string = resourceGroup().location

@description('Azure ML workspace name')
param workspaceName string

@description('Existing storage account name for datastore')
param storageAccountName string

@description('Existing storage account container name')
param containerName string

// Workspace
resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: workspaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Workspace created via Bicep'
    friendlyName: workspaceName
  }
}

// Datastore
resource blobDatastore 'Microsoft.MachineLearningServices/workspaces/datastores@2024-04-01' = {
  name: '${amlWorkspace.name}/blob-datastore'
  properties: {
    datastoreType: 'AzureBlob'
    accountName: storageAccountName
    containerName: containerName
    credentials: {
      credentialsType: 'None'
    }
  }
}

// Compute (example AML compute cluster)
resource cpuCluster 'Microsoft.MachineLearningServices/workspaces/computes@2024-04-01' = {
  name: '${amlWorkspace.name}/cpu-cluster'
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: 'STANDARD_DS11_V2'
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 2
        nodeIdleTimeBeforeScaleDown: 'PT5M'
      }
    }
  }
}
