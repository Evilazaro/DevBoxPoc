@description('Name of the solution to deploy')
param solutionName string

@description('Deploy Management Resources')
module managementResources './management/logAnalytics/deploy.bicep' = {
  name: 'managementResources'
  params: {
    solutionName: solutionName
  }
}

@description('Log Analytics Id')
output managementResourcesId string = managementResources.outputs.logAnalyticsWorkspaceId

@description('Log Analytics Name')
output managementResourcesName string = managementResources.outputs.logAnalyticsWorkspaceName

@description('Deploy Network Resources')
module networkResources './network/deploy.bicep' = {
  name: 'networkResources'
  params: {
    solutionName: solutionName
  }
  dependsOn: [
    managementResources
  ]
}

@description('Virtual Network Id')
output networkResourcesId string = networkResources.outputs.vnetId

@description('Virtual Network Name')
output networkResourcesName string = networkResources.outputs.vnetName


@description('Deploy DevCenter Resources')
module devCenterResources './devBox/deploy.bicep' = {
  name: 'devCenterResources'
  params: {
    solutionName: solutionName
  }
  dependsOn: [
    networkResources
  ]
}
