@description('Dev Center Name')
param devCenterName string

@description('Projects')
param workloadProjectsInfo array

@description('Dev Box Definitions')
param devBoxDefinitions array

@description('Role Definition Ids')
param roleDefinitions array

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Dev Center Project Resource')
resource projects 'Microsoft.DevCenter/projects@2024-10-01-preview' = [
  for project in workloadProjectsInfo: {
    name: project.name
    location: resourceGroup().location
    properties: {
      displayName: project.name
      devCenterId: devCenter.id
      maxDevBoxesPerUser: 10
      catalogSettings: {
        catalogItemSyncTypes: [
          'EnvironmentDefinition'
          'ImageDefinition'
        ]
      }
      description: project.name
    }

    identity: {
      type: 'SystemAssigned'
    }
    tags: project.tags
  }
]

@description('Project Role Assignments')
module roleAssignments '../../../identity/roleAssignmentResource.bicep' = [
  for (project, i) in workloadProjectsInfo: {
    scope: subscription()
    name: '${projects[i].name}-${resourceGroup().location}-roleAssignments'
    params: {
      principalId: projects[i].identity.principalId
      roleDefinitions: roleDefinitions
    }
  }
]

@description('Project Catalogs')
module projectCatalogs 'projectCatalogResource.bicep' = [
  for (project, i) in workloadProjectsInfo: {
    scope: resourceGroup()
    name: '${projects[i].name}-catalogs'
    params: {
      projectName: project.name
      projectCatalogsInfo: project.catalogs
    }
  }
]

@description('Dev Box Pools')
module devBoxPools 'devBoxPoolsResource.bicep' = [
  for (project, i) in workloadProjectsInfo: {
    name: '${projects[i].name}-devBoxPools'
    scope: resourceGroup()
    params: {
      projectName: project.name
      devBoxDefinitions: devBoxDefinitions
      networkConnectionName: project.networkConnectionName
    }
  }
]
