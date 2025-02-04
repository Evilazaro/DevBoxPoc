param devCenterName string
var catalogInfo = {
  name: 'Dev-Box-Catalog'
  branch: 'main'
  uri: 'https://github.com/Evilazaro/DevBoxPoc.git'
  path: '/customizations/tasks'
}

@description('Existent DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
}

@description('Attache the DevCenter Catalog to the DevCenter')
resource projectCatalog 'Microsoft.DevCenter/devcenters/catalogs@2024-10-01-preview' = {
  name: '${catalogInfo.name}-catalog'
  parent: devCenter
  properties: {
    gitHub: {
      uri: catalogInfo.uri
      branch: catalogInfo.branch
      path: catalogInfo.path
    }
    syncType: 'Scheduled'
  }
}

@description('Dev Center Catalog Name')
output catalogName string = projectCatalog.name

@description('Dev Center Catalog Id')
output catalogId string = projectCatalog.id

@description('Dev Center Catalog Uri')
output catalogUri string = projectCatalog.properties.gitHub.uri
