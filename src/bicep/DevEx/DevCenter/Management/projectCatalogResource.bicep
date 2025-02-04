@description('Project Name')
param projectName string

@description('Project Catalogs Info')
param projectCatalogsInfo array

resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectName
  scope: resourceGroup()
}

resource projectCatalog 'Microsoft.DevCenter/projects/catalogs@2024-10-01-preview' = [
  for catalog in projectCatalogsInfo: {
    name: catalog.catalogName
    parent: project
    properties: {
      gitHub: {
        uri: catalog.uri
        branch: catalog.branch
        path: catalog.path
      }
    }
  }
]
