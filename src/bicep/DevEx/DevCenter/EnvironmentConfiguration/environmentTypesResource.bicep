@description('Dev Center Name')
param devCenterName string

param environmentTypesInfo array

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Environment Type Resource')
resource environmentType 'Microsoft.DevCenter/devcenters/environmentTypes@2024-10-01-preview' = [
  for environmentType in environmentTypesInfo: {
    name: environmentType.name
    parent: devCenter
    tags: environmentType.tags
  }
]
