using 'br/public:avm/res/elastic-san/elastic-san:0.1.0'

// Required parameters
param name = 'test'
// Non-required parameters
param availabilityZone = 1
param baseSizeTiB = 2
param extendedCapacitySizeTiB = 5
param publicNetworkAccess = 'Enabled'
param sku = 'Premium_LRS'
param tags = {
  environment: 'sbx'
  applicationName: 'Microsoft Elastic SAN'
  owner: 'Stephen Tulp'
  criticality: 'Tier1'
  costCenter: '1234'
  contactEmail: 'stephen.tulp@xxxxxxxxxxx.onmicrosoft.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
param volumeGroups = [
  {
    name: 'volumeGroup1'
    virtualNetworkRules: [
      {
        virtualNetworkSubnetResourceId: '<virtualNetworkSubnetResourceId>'
      }
    ]
    volumes: [
      {
        name: 'volume1'
        sizeGiB: 500
      }
      {
        name: 'volume2'
        sizeGiB: 500
      }
    ]
  }
]
