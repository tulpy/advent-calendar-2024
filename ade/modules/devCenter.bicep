import * as shared from '../configuration/shared/shared.conf.bicep'
import * as type from '../configuration/shared/shared.types.bicep'

@description('An object of Tag key & value pairs to be appended to a Subscription.')
param tags object?

param location string
param devCenterName string
param subnetId string = ''
param networkingResourceGroupName string

var devCenterEnvironments = [
  'sandbox'
  'development'
  'test'
  'production'
]

var image = {
  'win11-ent-base': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win11-ent-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win11-ent-vs2022': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

/*
var compute = {
  '8c-32gb': 'general_i_8c32gb256ssd_v2'
  '16c-64gb': 'general_i_16c64gb512ssd_v2'
  '32c-128gb': 'general_i_32c128gb1024ssd_v2'
}
*/

var skus = {
  '8-vcpu-32gb-ram-256-ssd': 'general_i_8c32gb256ssd_v2'
  '8-vcpu-32gb-ram-512-ssd': 'general_i_8c32gb512ssd_v2'
  '8-vcpu-32gb-ram-1024-ssd': 'general_i_8c32gb1024ssd_v2'
  '8-vcpu-32gb-ram-2048-ssd': 'general_i_8c32gb2048ssd_v2'
  '16-vcpu-64gb-ram-256-ssd': 'general_i_16c64gb256ssd_v2'
  '16-vcpu-64gb-ram-512-ssd': 'general_i_16c64gb512ssd_v2'
  '16-vcpu-64gb-ram-1024-ssd': 'general_i_16c64gb1024ssd_v2'
  '16-vcpu-64gb-ram-2048-ssd': 'general_i_16c64gb2048ssd_v2'
  '32-vcpu-128gb-ram-512-ssd': 'general_i_32c128gb512ssd_v2'
  '32-vcpu-128gb-ram-1024-ssd': 'general_i_32c128gb1024ssd_v2'
  '32-vcpu-128gb-ram-2048-ssd': 'general_i_32c128gb2048ssd_v2'
}

// Resource: Dev Center
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
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
  parent: devCenter
  name: 'azure-verifed-modules'
  properties: {
    gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
      path: 'Environment-Definitions'
    }
  }
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2023-01-01-preview' = if (!empty(subnetId)) {
  name: 'networkConnectionName'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: networkingResourceGroupName
  }
}

resource attachedNetworks 'Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview' = if (!empty(subnetId)) {
  parent: devCenter
  name: networkConnection.name
  properties: {
    networkConnectionId: networkConnection.id
  }
}

// Resource: Dev Box Definitions
resource devboxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview' = [
  for definition in shared.definitions: {
    parent: devCenter
    name: definition.name
    location: location
    properties: {
      imageReference: {
        id: '${devCenter.id}/galleries/default/images/${image[definition.image]}'
      }
      sku: {
        name: skus[definition.sku]
      }
    }
    dependsOn: []
  }
]

// Resource: Environment Type
resource devcenterEnvironments 'Microsoft.DevCenter/devcenters/environmentTypes@2023-04-01' = [for item in devCenterEnvironments: {
  parent: devCenter
  name: item
  tags: tags
}
]

output devCenterName string = devCenter.name

output definitions array = [
  for (definition, i) in shared.definitions: {
    name: devboxDefinitions[i].name
  }
]
