import * as shared from '../configuration/shared/shared.conf.bicep'

@description('An object of Tag key & value pairs to be appended to a Subscription.')
param tags object?

param location string
param devCenterName string
param projectName string
param environmentTypeName string
param userObjectId string

var roles = [
  {
    id: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    properties: {}
  }
]

var image = {
  'win11-ent-base': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win11-ent-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win11-ent-vs2022': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

var compute = {
  '8c-32gb': 'general_i_8c32gb256ssd_v2'
  '16c-64gb': 'general_i_16c64gb512ssd_v2'
  '32c-128gb': 'general_i_32c128gb1024ssd_v2'
}

// Resource: Dev Center
resource devcenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: devCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: 'Enabled'
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: 'Enabled'
    }
  }
}

// Resource: Quickstart Environment Definitions
resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2023-04-01' = {
  parent: devcenter
  name: 'azure-verifed-modules'
  properties: {
    gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
      path: 'Environment-Definitions'
    }
  }
}

// Resource: Dev Box Definitions
resource devboxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2022-11-11-preview' = [
  for definition in shared.definitions: {
    parent: devcenter
    name: definition.name
    location: location
    properties: {
      imageReference: {
        id: '${devcenter.id}/galleries/default/images/${image[definition.image]}'
      }
      sku: {
        name: compute[definition.compute]
      }
      osStorageType: 'ssd_${definition.storage}'
    }
    dependsOn: []
  }
]

// Resource: Environment Type
resource devcenterEnvironmentType 'Microsoft.DevCenter/devcenters/environmentTypes@2023-04-01' = {
  parent: devcenter
  name: environmentTypeName
  tags: tags
}

// Resource: Project
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: projectName
  dependsOn: [
    devcenterEnvironmentType
    devboxDefinitions
  ]
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  tags: tags
  properties: {
    devCenterId: devcenter.id
    maxDevBoxesPerUser: 2
  }
  // Resource: Project Environment Pools
  resource pools 'pools' = [
    for pool in shared.pools: {
      name: pool.name
      location: location
      properties: {
        devBoxDefinitionName: pool.definition
        displayName: pool.displayName
        licenseType: 'Windows_Client'
        localAdministrator: pool.administrator
        managedVirtualNetworkRegions: [
          location
        ]
        networkConnectionName: 'managedNetwork'
        singleSignOnStatus: 'Enabled'
        stopOnDisconnect: {
          status: 'Enabled'
          gracePeriodMinutes: 60
        }
        stopOnNoConnect: {
          status: 'Enabled'
          gracePeriodMinutes: 60
        }
        virtualNetworkType: 'Managed'
      }
    }
  ]
}

// Module: Resource Role Assignment - https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/authorization/resource-role-assignment
module resourceRoleAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (userObjectId != '') {
  name: take('resourceRoleAssignment-${guid(deployment().name)}', 64)
  params: {
    // Required parameters
    principalId: userObjectId
    resourceId: project.id
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '18e40d4e-8d2e-438d-97e1-9528336e149c'
    )
    // Non-required parameters
    description: 'Provides access to manage environment resources.'
    principalType: 'User'
  }
}

// Resource: Project Environment Types
resource projectEnvironmentType 'Microsoft.DevCenter/projects/environmentTypes@2024-10-01-preview' = {
  parent: project
  name: environmentTypeName
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
  }
}

output devCenterName string = devcenter.name

output definitions array = [for (definition, i) in shared.definitions: {
  name: devboxDefinitions[i].name
}]

output projectName string = project.name

output poolNames array = [for (pool, i) in shared.pools: {
  name: project::pools[i].name
}]
