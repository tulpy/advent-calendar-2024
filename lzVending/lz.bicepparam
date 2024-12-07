using 'br/public:avm/ptn/lz/sub-vending:0.2.1'

param subscriptionAliasEnabled = false
param existingSubscriptionId = '0b5d0018-2879-4810-b8d7-4f8dda5ce0b9'
param resourceProviders = {}
param roleAssignmentEnabled = true
param roleAssignments = [
  {
    definition: '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    principalId: '2b33ff60-edf0-4216-b2a6-66ec07050fd4'
    relativeScope: '/'
  }
]
param subscriptionTags = {
    environment: envPrefix
    applicationName: 'SAP Landing Zone'
    owner: 'Platform Team'
    criticality: 'Tier2'
    costCenter: '1234'
    contactEmail: 'stephen.tulp@outlook.com'
    dataClassification: 'Internal'
    iac: 'Bicep'
}
param hubNetworkResourceId = '/subscriptions/5cb7efe0-67af-4723-ab35-0f2b42a85839/resourceGroups/arg-syd-plat-conn-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-plat-conn-10.52.0.0_24'
param virtualNetworkEnabled = true
param virtualNetworkAddressSpace = [
  '10.52.1.0/24'
]
param virtualNetworkName = 'vnt-syd-plat-sap-10.52.1.0_24'
param virtualNetworkPeeringEnabled = true
param virtualNetworkResourceGroupName = 'arg-syd-plat-conn-network'
param virtualNetworkUseRemoteGateways = false

var envPrefix = 'sbx'
