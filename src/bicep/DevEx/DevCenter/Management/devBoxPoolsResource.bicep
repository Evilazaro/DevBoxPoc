@description('Project Name')
param projectName string

@description('DevBox Definitions')
param devBoxDefinitions array

@description('Network Connection Name')
param networkConnectionName string

@description('Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectName
  scope: resourceGroup()
}

@description('Dev Box Pools')
resource devBoxPools 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [
  for devBoxDefinition in devBoxDefinitions: {
    name: '${projectName}-${devBoxDefinition.name}-pool'
    parent: project
    location: resourceGroup().location
    properties: {
      devBoxDefinitionName: devBoxDefinition.name
      localAdministrator: 'Enabled'
      licenseType: 'Windows_Client'
      networkConnectionName: networkConnectionName
      singleSignOnStatus: 'Enabled'
      virtualNetworkType: 'Unmanaged'
    }
  }
]
