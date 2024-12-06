@description('Solution Name')
param solutionName string

@description('The name of the virtual network')
var vnetName = 'AG_Windows365_PRD_01_EASTUS2_01_VNET'

@description('The name of the resource group of the virtual network')
var vnetResourceGroupName = 'AG_PRD_01_NRG'

@description('The tags of the virtual network')
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Network'
}

@description('The address prefix of the subnet')
var subNets = [
  {
    name: 'Subnet_10.232.96.0_19'
    addressPrefix: '10.0.0.0/24'
  }
]

@description('Deploy the network connection for each subnet')
module netConnection 'networkConnection/networkConnection.bicep' = [
  for subnet in subNets: {
    name: '${subnet.name}-con'
    params: {
      name: '${subnet.name}-con'
      vnetName: vnetName
      subnetName: subnet.name
      vnetResourceGroupName: vnetResourceGroupName
      tags: tags
    }
  }
]
