using './fabric.bicep'

param name = 'tulpyfabric'
param skuName = 'F2'
param adminUsers = [
  'stephen.tulp@insightaudemo.onmicrosoft.com'
]
param tags = {
  environment: 'test'
  applicationName: 'Microsoft Fabric'
  owner: 'Data Team'
  criticality: 'Tier1'
  costCenter: '1234'
  contactEmail: 'stephen.tulp@insightaudemo.onmicrosoft.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
