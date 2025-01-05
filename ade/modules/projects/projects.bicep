import * as shared from '../../configuration/shared/shared.conf.bicep'
import * as type from '../../configuration/shared/shared.types.bicep'

targetScope = 'resourceGroup'

@description('Optional. The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@description('Optional. An object of Tag key & value pairs to be appended to a Subscription.')
param tags type.tagsType

@description('Required. The Dev Box Project Configuration object.')
param projectConfig type.projectType

@description('Required. The Microsoft Dev Center Resource Id.')
param devCenterId string

@description('Optional. The Subnet Id to deploy the resources into, if it is empty Microsoft networking will be used.')
param subnetId string = ''

// Variables
var devCenterResourceGroup = (split(devCenterId, '/')[4])
var devCenterName = (split(devCenterId, '/')[8])
var roles = [
  {
    id: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    properties: {}
  }
]

// Resource: Microsoft Dev Center
resource devcenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
  scope: az.resourceGroup(devCenterResourceGroup)
}

// Module: Resource Role Assignment - https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/authorization/resource-role-assignment
module resourceRoleAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (projectConfig.groupObjectId != '') {
  name: take('resourceRoleAssignment-${guid(deployment().name)}', 64)
  params: {
    // Required parameters
    principalId: projectConfig.groupObjectId
    resourceId: projects.id
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '45d50f46-0b78-4001-a660-4198cbe8cd05' // DevCenter Dev Box User - https://www.azadvertizer.net/azrolesadvertizer/45d50f46-0b78-4001-a660-4198cbe8cd05.html
    )
    // Non-required parameters
    description: 'Provides access to manage environment resources.'
    principalType: 'Group'
  }
}

// Resource: Microsoft Dev Box Projects
resource projects 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: toLower(projectConfig.name)
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    devCenterId: devcenter.id
    description: projectConfig.description
    displayName: projectConfig.displayName
    maxDevBoxesPerUser: projectConfig.maxDevBoxesPerUser
  }
}

// Resource: Project Environment Types
resource projectEnvironmentType 'Microsoft.DevCenter/projects/environmentTypes@2024-10-01-preview' = {
  parent: projects
  name: 'sandbox'
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    status: 'Enabled'
    deploymentTargetId: subscription().id
    creatorRoleAssignment: {
      roles: toObject(roles, role => role.id, role => role.properties)
    }
    userRoleAssignments: {
      roles: {}
    }
  }
}

// Module: Microsoft Dev Box Pools
@batchSize(1)
module pools './pools/pools.bicep' = [
  for (pool, index) in projectConfig.pools: {
    name: 'Microsoft.DevCenter.Projects.${index}.Pools'
    dependsOn: [
      projects
    ]
    params: {
      projectConfig: projectConfig
      location: location
      subnetId: subnetId
    }
  }
]
