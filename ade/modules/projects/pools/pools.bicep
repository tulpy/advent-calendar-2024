targetScope = 'resourceGroup'

// ----------
// Parameters
// ----------

param project object
param location string
param connectionName string
param subnetId string

// Pools
resource pools 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = [for pool in project.pools: {
  name: pool.name
  location: location
  parent: parent
  properties: {
    devBoxDefinitionName: pool.devBoxDefinitionName
    displayName: pool.displayName
    licenseType: pool.licenseType
    localAdministrator: pool.localAdministrator
    managedVirtualNetworkRegions: !empty(subnetId) ? [] : location
    networkConnectionName: !empty(subnetId) ? pool.networkConnectionName : 'managedNetwork'
    singleSignOnStatus: pool.singleSignOnStatus
    stopOnDisconnect: {
      status: pool.StopOnDisconnect.status
      gracePeriodMinutes: pool.StopOnDisconnect.gracePeriodMinutes
    }
    stopOnNoConnect: {
      status: pool.stopOnNoConnect.status
      gracePeriodMinutes: pool.stopOnNoConnect.gracePeriodMinutes
    }
    virtualNetworkType: !empty(subnetId) ? 'Unmanaged' : 'Managed'
  }
}]

// ---------
// Resources
// ---------

resource parent 'Microsoft.DevCenter/projects@2023-04-01' existing = {
  name: project.name
}

