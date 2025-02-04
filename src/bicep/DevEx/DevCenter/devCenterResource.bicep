@description('Dev Center name')
param name string

@description('Workload Role Definitions')
param workloadRoleDefinitions array

@description('Network Connections')
param networkConnectionsCreated array

@description('Contoso Dev Center Catalog')
param workloadCatalogInfo object

@description('Projects')
param workloadProjectsInfo array

@description('Environment Types Info')
param environmentTypesInfo array

@description('Contoso Dev Center Dev Box Definitions')
param workloadDevBoxDefinitionsInfo array

@description('Location')
param location string

@description('Catalog Item Sync Enable Status')
@allowed([
  'Enabled'
  'Disabled'
])
param catalogItemSyncEnableStatus string

@description('Microsoft Hosted Network Enable Status')
@allowed([
  'Enabled'
  'Disabled'
])
param microsoftHostedNetworkEnableStatus string

@description('Install Azure Monitor Agent Enable Status')
@allowed([
  'Enabled'
  'Disabled'
])
param installAzureMonitorAgentEnableStatus string

@description('Tags')
param tags object = {
  workload: '${name}-DevExp'
  landingZone: 'DevExp'
  resourceType: 'DevCenter'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: 'DevExp-${uniqueString(resourceGroup().id, name)}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: catalogItemSyncEnableStatus
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: installAzureMonitorAgentEnableStatus
    }
  }
}

@description('Role Assignment Resource')
module roleAssignments '../../identity/roleAssignmentResource.bicep' = {
  scope: subscription()
  name: 'roleAssignments'
  params: {
    principalId: devCenter.identity.principalId
    roleDefinitions: workloadRoleDefinitions
  }
}

@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'NetworkConnection/networkConnectionAttachmentResource.bicep' = {
  name: 'networkAttachments'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.name
    networkConnectionsCreated: networkConnectionsCreated
  }
}

@description('Environment Type Resource')
module environmentTypes 'EnvironmentConfiguration/environmentTypesResource.bicep' = {
  name: 'environmentTypes'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.name
    environmentTypesInfo: environmentTypesInfo
  }
}

@description('Contoso Dev Center Catalog')
module catalog 'EnvironmentConfiguration/devCentercatalogsResource.bicep' = {
  name: 'catalog'
  scope: resourceGroup()
  params: {
    name: workloadCatalogInfo.name
    tags: tags
    branch: workloadCatalogInfo.branch
    devCenterName: devCenter.name
    path: workloadCatalogInfo.path
    syncType: workloadCatalogInfo.syncType
    type: workloadCatalogInfo.type
    uri: workloadCatalogInfo.uri
  }
  dependsOn: [
    roleAssignments
  ]
}

@description('Dev Center Dev Box Definitions')
module devBoxDefinitions 'EnvironmentConfiguration/devBoxDefinitionResource.bicep' = {
  name: 'devBoxDefinitions'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.name
    devBoxDefinitionsInfo: workloadDevBoxDefinitionsInfo
  }
  dependsOn: [
    networkConnectionAttachment
    roleAssignments
  ]
}

@description('Contoso Dev Center Projects')
module projects 'Management/projectModule.bicep' = {
  name: 'projects'
  scope: resourceGroup()
  params: {
    devBoxDefinitions: devBoxDefinitions.outputs.devBoxDefinitions
    devCenterName: devCenter.name
    roleDefinitions: workloadRoleDefinitions
    workloadProjectsInfo: workloadProjectsInfo
  }
}
