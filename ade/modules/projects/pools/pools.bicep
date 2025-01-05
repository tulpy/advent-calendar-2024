targetScope = 'resourceGroup'

@description('Required. The Dev Box Project Configuration object.')
param projectConfig object

@description('Optional. The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@description('Optional. The Subnet Id to deploy the resources into, if it is empty Microsoft networking will be used.')
param subnetId string = ''

// Resource: Microsoft Dev Center Project
resource parent 'Microsoft.DevCenter/projects@2023-04-01' existing = {
  name: projectConfig.name
}

// Resource: Microsoft Dev Box Project Pools
resource pools 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [
  for pool in projectConfig.pools: {
    name: toLower(pool.name)
    location: location
    parent: parent
    properties: {
      devBoxDefinitionName: pool.devBoxDefinitionName
      displayName: pool.displayName
      licenseType: pool.licenseType
      localAdministrator: pool.localAdministrator
      managedVirtualNetworkRegions: !empty(subnetId) ? [] : location // If the Subnet Id is empty, then the Managed Virtual Network Regions is the Location
      networkConnectionName: !empty(subnetId) ? pool.networkConnectionName : 'managedNetwork' // If the Subnet Id is empty, then the Network Connection Name is managedNetwork
      singleSignOnStatus: pool.singleSignOnStatus
      stopOnDisconnect: {
        status: pool.stopOnDisconnect.status
        gracePeriodMinutes: pool.stopOnDisconnect.gracePeriodMinutes
      }
      stopOnNoConnect: {
        status: pool.stopOnNoConnect.status
        gracePeriodMinutes: pool.stopOnNoConnect.gracePeriodMinutes
      }
      virtualNetworkType: !empty(subnetId) ? 'Unmanaged' : 'Managed' // If the Subnet Id is empty, then the Virtual Network Type is Managed
    }
  }
]
