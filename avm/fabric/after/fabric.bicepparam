using 'br/public:avm/res/fabric/capacity:0.1.1'

// Required parameters
param adminMembers = [
  'stephen.tulp@insightaudemo.onmicrosoft.com'
]
param name = 'tulpyfabric'
// Non-required parameters
param skuName = 'F2'
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
