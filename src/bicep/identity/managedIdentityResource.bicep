@description('Workload Name')
param name string 

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: '${name}-${uniqueString(resourceGroup().id,name)}-identity'
  location: resourceGroup().location
}

@description('Managed Identity Principal Id')
output principalId string = identity.properties.principalId
