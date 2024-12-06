
@description('Network Connection Name')
param name string

@description('Subnet Id')
param vnetName string

@description('Subnet Name')
param subnetName string

@description('Virtual Network Resource Group Name')
param vnetResourceGroupName string

@description('Tags for the Network Connection')
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' existing = {
  name: subnetName
  parent: vnet
}


@description('Deploy a network connection to Azure')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    domainJoinType: 'HybridAzureADJoin' 
    subnetId: subnet.id
  }
  dependsOn: [
    subnet
  ]
}

@description('Network Connection Name')
output name string = networkConnection.name

@description('Network Connection Id') 
output id string = networkConnection.id
