using 'br/public:avm/res/elastic-san/elastic-san:0.1.0'

param name = 'test'
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
        virtualNetworkSubnetResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/arg-syd-lz-prd-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-lz-prd-10.15.0.0_24/subnets/app'
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
