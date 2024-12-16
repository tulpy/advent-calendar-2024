import * as shared from '../configuration/shared/shared.conf.bicep'

using '../main.bicep'

param lzPrefix = 'sap'
param envPrefix = 'sbx'
param tags = {
  environment: envPrefix
  applicationName: 'SAP Landing Zone'
  owner: 'Platform Team'
  criticality: 'Tier2'
  costCenter: '1234'
  contactEmail: 'test@test.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
param userObjectId = 'e5906c27-d401-4768-9c79-1dab42fd1a80'
param environmentTypeName = 'Sandbox'

