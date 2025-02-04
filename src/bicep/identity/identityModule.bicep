@description('Workload Name')
param workloadName string 

@description('Workload Role Definitions')
param workloadRoleDefinitions array

module managedIdentity 'managedIdentityResource.bicep' = {
  name: 'managedIdentity'
  scope: resourceGroup()
  params: {
    name: workloadName
  }
}

@description('Managed Identity Role Assignment')
module roleAssignments 'roleAssignmentResource.bicep' = {
  name: '${workloadName}-${resourceGroup().location}-roleAssignments'
  scope: subscription()
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitions: workloadRoleDefinitions
  }
}

@description('Role Definition Ids')
output roleDefinitions array = workloadRoleDefinitions
