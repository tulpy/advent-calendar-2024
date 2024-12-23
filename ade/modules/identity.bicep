targetScope = 'subscription'

param devCenterName string
param resourceGroupName string
param userObjectId string
param projectId string

resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  scope: resourceGroup(resourceGroupName)
  name: devCenterName
}

resource uaaRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('uaaRoleAssignment')
  properties: {
    description: 'Lets you manage user access to Azure resources.'
    principalId: devcenter.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
  }
}

resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('contributorRoleAssignment')
  properties: {
    description: 'Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries.'
    principalId: devcenter.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
}

// Module: Resource Role Assignment - https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/authorization/resource-role-assignment
module resourceRoleAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (userObjectId != '') {
  name: take('resourceRoleAssignment-${guid(deployment().name)}', 64)
  scope: resourceGroup(resourceGroupName)
  params: {
    // Required parameters
    principalId: userObjectId
    resourceId: projectId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '18e40d4e-8d2e-438d-97e1-9528336e149c'
    )
    // Non-required parameters
    description: 'Provides access to manage environment resources.'
    principalType: 'User'
  }
}
