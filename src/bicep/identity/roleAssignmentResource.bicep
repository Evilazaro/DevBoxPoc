@description('Dev Center Name')
param principalId string 

@description('Role Definition Ids')
param roleDefinitions array 

targetScope = 'subscription'

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleDefinition in roleDefinitions: {
    name: guid(subscription().id, principalId, roleDefinition)
    scope: subscription()
    properties: {
      principalId: principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinition)
      principalType: 'ServicePrincipal'
    }
  }
]
