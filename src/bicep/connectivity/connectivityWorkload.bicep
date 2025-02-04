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
  for subnet in workloadConnectivityInfo: {
    name: '${subnet.subNetName}-con'
    scope: resourceGroup(rgConnectivityName)
    params: {
      subnetName: subnet.subNetName
      virtualNetworkName: subnet.vnetName
      virtualNetworkResourceGroupName: subnet.vnetResourceGroupName
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
