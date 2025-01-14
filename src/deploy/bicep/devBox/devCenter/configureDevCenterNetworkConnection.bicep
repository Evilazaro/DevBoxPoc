@description('Dev Center Name')
param devCenterName string

@description('Network Connection Name')
param networkConnectionName string

@description('Existent Natwork Connection')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' existing = {
  name: networkConnectionName
}

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
}

@description('Create DevCenter Network Connection')
resource devCenterNetworkConnection 'Microsoft.DevCenter/devcenters/attachednetworks@2024-10-01-preview' = {
  parent: devCenter
  name: networkConnection.name
  properties: {
    networkConnectionId: format(
      '/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DevCenter/networkConnections/{2}',
      subscription().subscriptionId,
      resourceGroup().name,
      networkConnection.name
    )
  }
}

@description('DevCenter Network Connection Name')
output devCenterNetworkConnectionName string = devCenterNetworkConnection.name

