import * as shared from '../configuration/shared/shared.conf.bicep'

using '../main.bicep'

param lzPrefix = 'sap'
param envPrefix = 'sbx'
param tags = {
  environment: envPrefix
  applicationName: 'Azure Dev Environments'
  owner: 'Platform Team'
  criticality: 'Tier2'
  costCenter: '1234'
  contactEmail: 'test@test.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
param userObjectId = 'e5906c27-d401-4768-9c79-1dab42fd1a80'
param environmentTypeName = 'Sandbox'
param existingSubnetId = '/subscriptions/0b5d0018-2879-4810-b8d7-4f8dda5ce0b9/resourceGroups/arg-syd-sap-sbx-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-sap-sbx-10.52.1.0_24/subnets/app'
