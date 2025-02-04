@description('Workload name')
param workloadName string

@description('Connectivity Info')
param workloadConnectivityInfo array

param rgConnectivityName string

@description('Tags')
param tags object = {
  workload: '${workloadName}-DevExp'
  landingZone: 'connectivity'
  resourceType: 'virtualNetwork'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

@description('Network Connection Resource')
module networkConnection 'networkConnection/networkConnectionResource.bicep' = [
  for (subnet, i) in workloadConnectivityInfo: {
    name: '${subnet[i].subNetName}-con'
    scope: resourceGroup(rgConnectivityName)
    params: {
      subnetName: subnet[i].subNetName
      virtualNetworkName: subnet[i].vnetName
      virtualNetworkResourceGroupName: subnet[i].vnetResourceGroupName
      tags: tags
    }
  }
]
@description('Network Connections')
output networkConnectionsCreated array = [
  for (netConnection, i) in workloadConnectivityInfo: {
    name: networkConnection[i].outputs.networkConnectionName
    id: networkConnection[i].outputs.networkConnectionId
  }
]
