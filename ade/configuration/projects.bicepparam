using '../modules/projects/projects.bicep'

param devCenterId = '/subscriptions/0b5d0018-2879-4810-b8d7-4f8dda5ce0b9/resourceGroups/arg-syd-sap-sbx-devcenter/providers/Microsoft.DevCenter/devcenters/adc-syd-sap-sbx-7c6ucm'
param subnetId = '/subscriptions/0b5d0018-2879-4810-b8d7-4f8dda5ce0b9/resourceGroups/arg-syd-sap-sbx-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-sap-sbx-10.52.1.0_24/subnets/app'
param tags = {
  environment: 'sbx'
  applicationName: 'Azure Dev Environments'
  owner: 'Platform Team'
  criticality: 'Tier2'
  costCenter: '1234'
  contactEmail: 'test@test.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
param projectConfig = {
    name: 'default'
    displayName: 'Default'
    description: 'This is the default project'
    maxDevBoxesPerUser: 2
    groupObjectId: '40f29607-4e3d-4501-b400-f57723b2ae8e'
    pools: [
      {
        name: 'standard'
        devBoxDefinitionName: 'win11-vs2022-vscode'
        displayName: 'Standard'
        licenseType: 'Windows_Client'
        localAdministrator: 'Enabled'
        networkConnectionName: 'networkConnectionName'
        singleSignOnStatus: 'Enabled'
        stopOnDisconnect: {
          status: 'Enabled'
          gracePeriodMinutes: 60
        }
        stopOnNoConnect: {
          status: 'Enabled'
          gracePeriodMinutes: 60
        }
      }
      {
        name: 'standard1'
        displayName: 'Standard'
        licenseType: 'Windows_Client'
        singleSignOnStatus: 'Enabled'
        networkConnectionName: 'networkConnectionName'
        stopOnDisconnect: {
          status: 'Enabled'
          gracePeriodMinutes: 60
        }
        stopOnNoConnect: {
          status: 'Enabled'
          gracePeriodMinutes: 60
        }
        devBoxDefinitionName: 'win11-vs2022-vscode'
        localAdministrator: 'Enabled'
      }
    ]
  }
