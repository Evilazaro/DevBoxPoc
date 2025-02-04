@description('Workload Name')
param workloadName string

@description('Param for Resource Group Name for Connectivity Resources')
param rgConnectivityName string

@description('Connectivity Info')
param workloadConnectivityInfo array

@description('Contoso Dev Center Catalog')
param workloadCatalogInfo object

@description('Environment Types Info')
param environmentTypesInfo array

@description('Contoso Dev Center Dev Box Definitions')
param workloadDevBoxDefinitionsInfo array

@description('Workload Role Definitions')
param workloadRoleDefinitions array

@description('Deploy Identity Resources')
module identityResources '../src/bicep/identity/identityModule.bicep' = {
  name: 'identity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    workloadRoleDefinitions: workloadRoleDefinitions
  }
}

@description('Deploy Connectivity Resources')
module connectivityResources '../src/bicep/connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    workloadConnectivityInfo: workloadConnectivityInfo
    rgConnectivityName: rgConnectivityName
  }
}

@description('Projects')
var workloadProjectsInfo = [
  {
    name: 'eShop'
    networkConnectionName: connectivityResources.outputs.networkConnectionsCreated[0].name
    catalogs: [
      {
        catalogName: 'imageDefinitions'
        uri: 'https://github.com/Evilazaro/eShop-k8s.git'
        branch: 'main'
        path: '/.configurations/imageDefinitions'
      }
      {
        catalogName: 'environments'
        uri: 'https://github.com/Evilazaro/eShop-k8s.git'
        branch: 'main'
        path: '/.configurations/environments'
      }
    ]
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'eShop'
    }
  }
  {
    name: 'identityProvider'
    networkConnectionName: connectivityResources.outputs.networkConnectionsCreated[1].name
    catalogs: [
      {
        catalogName: 'imageDefinitions'
        uri: 'https://github.com/Evilazaro/IdentityProvider.git'
        branch: 'main'
        path: '/.configuration/devcenter/imageDefinitions'
      }
      {
        catalogName: 'environments'
        uri: 'https://github.com/Evilazaro/IdentityProvider.git'
        branch: 'main'
        path: '/.configuration/devcenter/environments/dev'
      }
    ]
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'identityProvider'
    }
  }
]

@description('Deploy DevEx Resources')
module devExResources '../src/bicep/DevEx/DevCenter/devCenterResource.bicep' = {
  name: 'workload'
  params: {
    name: workloadName
    location: resourceGroup().location
    catalogItemSyncEnableStatus: 'Enabled'
    workloadCatalogInfo: workloadCatalogInfo
    environmentTypesInfo: environmentTypesInfo
    installAzureMonitorAgentEnableStatus: 'Enabled'
    microsoftHostedNetworkEnableStatus: 'Enabled'
    networkConnectionsCreated: connectivityResources.outputs.networkConnectionsCreated
    workloadDevBoxDefinitionsInfo: workloadDevBoxDefinitionsInfo
    workloadProjectsInfo: workloadProjectsInfo
    workloadRoleDefinitions: workloadRoleDefinitions
  }
  dependsOn: [
    identityResources
  ]
}
