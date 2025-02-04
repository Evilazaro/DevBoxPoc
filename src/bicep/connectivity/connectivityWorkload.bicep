@description('Workload name')
param workloadName string

@description('Connectivity Info')
param workloadConnectivityInfo array

param connectivityResourceGroupName string

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
  for (netConnection, i) in workloadConnectivityInfo: {
    name: 'netCon-${netConnection.name}'
    scope: resourceGroup(connectivityResourceGroupName)
    params: {
      virtualNetworkName: netConnection[i].vnetName
      subnetName: netConnection[i].subnetName
      virtualNetworkResourceGroupName: netConnection[i].vnetResourceGroupName
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
