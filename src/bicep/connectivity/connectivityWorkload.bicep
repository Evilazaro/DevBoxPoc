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
    name: 'netCon-${netConnection.subnetName}'
    scope: resourceGroup(connectivityResourceGroupName)
    params: {
      virtualNetworkName: netConnection.vnetName
      subnetName: netConnection.subnetName
      virtualNetworkResourceGroupName: netConnection.vnetResourceGroupName
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
