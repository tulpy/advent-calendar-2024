targetScope = 'subscription'

metadata name = 'ALZ Bicep - Microsoft Entra Privilaged Identity Management Role Assignment'
metadata description = 'Module used to assign Entra PIM assignments to the subscription.'
metadata version = '1.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('Required. Role Definition Id (i.e. GUID, Reader Role Definition ID: acdd72a7-3385-48ef-bd42-f606fba81ae7).')
param roleDefinitionId string

@description('Required. Object ID of the Security Group or User for the PIM Role Assignment.')
param assigneeObjectId string

@description('Generated. Start time for the Role Assignment.')
param startTime string = utcNow()

// Resource: Microsoft Entra Privilaged Role Assignment
resource privilagedRoleAssignment 'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview' = {
  name: guid(subscription().subscriptionId, roleDefinitionId, assigneeObjectId)
  properties: {
    principalId: assigneeObjectId
    requestType: 'AdminUpdate'
    roleDefinitionId: roleDefinitionId
    scheduleInfo: {
      expiration: {
        duration: 'P365D'
        type: 'AfterDuration'
      }
      startDateTime: startTime
    }
  }
}
