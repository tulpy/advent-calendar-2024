import * as shared from '../../configuration/shared/shared.conf.bicep'
import * as type from '../../configuration/shared/shared.types.bicep'

targetScope = 'resourceGroup'

@description('Optional. The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@description('Optional. An object of Tag key & value pairs to be appended to a Subscription.')
param tags type.tagsType

param projectConfig object
param devCenterId string
param subnetId string = ''

var devCenterResourceGroup = (split(devCenterId, '/')[4])
var devCenterName = (split(devCenterId, '/')[8])

resource devcenter 'Microsoft.DevCenter/devcenters@2024-02-01' existing = {
  name: devCenterName
  scope: az.resourceGroup(devCenterResourceGroup)
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (projectConfig.userObjectId != '') {
  name: guid('project-user', projectConfig.name, projectConfig.userObjectId)
  properties: {
    description: 'Provides access to manage environment resources.'
    principalId: projectConfig.userObjectId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '45d50f46-0b78-4001-a660-4198cbe8cd05'
    )
  }
}

// Projects
resource projects 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: projectConfig.name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    devCenterId: devcenter.id
    description: projectConfig.description
    maxDevBoxesPerUser: projectConfig.maxDevBoxesPerUser
  }
}

@batchSize(1)
module pools './pools/pools.bicep' = [
  for (pool, index) in projectConfig.pools: {
    name: 'Microsoft.DevCenter.Projects.${index}.Pools'
    dependsOn: [
      projects
    ]
    params: {
      project: projectConfig
      location: location
      connectionName: 'settings.resources.networkConnection.name'
      subnetId: subnetId
    }
  }
]
