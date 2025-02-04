@description('Solution Name')
param solutionName string

@description('Teams and Projects for the Dev Center')
var projects = [
  {
    name: 'eShop'
    description: 'eShop Reference Application - AdventureWorks'
    networkConnectionName: 'Subnet_10.232.96.0_19-con'
    catalog: {
      name: 'eShop'
      type: 'gitHub'
      uri: 'https://github.com/Evilazaro/eShop.git'
      branch: 'main'
      path: '/.devcenter/customizations/tasks'
    }
  }
]

@description('The name of the Dev Center')
var devCenterName = format('{0}DevCenter', solutionName)

var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'DevBox'
}

@description('Deploy the Managed Identity')
module identity '../identity/deploy.bicep' = {
  name: 'identity'
  params: {
    solutionName: solutionName
  }
}

@description('Deploy the Compute Gallery')
module computeGallery './computeGallery/deployComputeGallery.bicep' = {
  name: 'computeGallery'
  params: {
    solutionName: solutionName
    tags: tags
  }
  dependsOn: [
    identity
  ]
}

@description('Deploy the Dev Center')
module devCenter 'devCenter/deployDevCenter.bicep' = {
  name: 'devCenter'
  params: {
    name: devCenterName
    identityName: identity.outputs.identityName
    computeGalleryName: computeGallery.outputs.computeGalleryName
    projects: projects
    tags: tags
  }
  dependsOn: [
    computeGallery
  ]
}

@description('Dev Center Name')
output devCenterName string = devCenter.outputs.devCenterName

@description('Dev Center Id')
output devCenterId string = devCenter.outputs.devCenterId
