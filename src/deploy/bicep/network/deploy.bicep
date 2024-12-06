@description('Solution Name')
param solutionName string

@description('The name of the virtual network')
var vnetName = 'AG_Windows365_PRD_01_EASTUS2_01_VNET'

@description('The name of the resource group of the virtual network')
var vnetResourceGroupName = 'AG_Windows365_PRD_01_NRG'

@description('The tags of the virtual network')
var tags = {
  division: 'PlatformEngineeringTeam-DX'
  enrironment: 'Production'
  offering: 'DevBox-as-a-Service'
  solution: solutionName
  landingZone: 'Network'
}

@description('The address prefix of the virtual network')
var addressPrefix = [
  '10.0.0.0/16'
]

@description('The address prefix of the subnet')
var subNets = [
  {
    name: 'Subnet_10.232.96.0_19'
    addressPrefix: '10.0.0.0/24'
  }
]

@description('Getting the new Virtual Network Deployed')
resource vnetDeployed 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

@description('The name of the log analytics workspace')
var logAnalyticsWorkspaceName = '${solutionName}-logAnalytics'

@description('Getting the Log Analytics Deployed')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}

@description('Creating Virtual Network Diagnostic Settings')
resource virtualNetworkDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vnetName}-DiagnosticSettings'
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}

@description('Deploy Nsg')
module nsg '../security/networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    name: 'nsg'
    tags: tags
    securityRules:[]
  }
}

@description('Getting the new NSG Deployed')
resource nsgDeployed 'Microsoft.Network/networkSecurityGroups@2024-03-01' existing = {
  name: 'nsg-nsg'
}

@description('NSG Diagnostic Settings')
resource nsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${nsg.name}-DiagnosticSettings'
  scope: nsgDeployed
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
  dependsOn: [
    nsgDeployed
    logAnalyticsWorkspace
  ]
}

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
