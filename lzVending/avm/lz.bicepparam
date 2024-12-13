using 'br/public:avm/ptn/lz/sub-vending:0.2.4'

var envPrefix = 'sbx'
var lzPrefix = 'sap'
var locPrefix = 'syd'
var argPrefix = 'arg'
var virtualNetworkPrefix = 'vnt'

param subscriptionAliasEnabled = false
param existingSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' //Update Subscription ID
param resourceProviders = {}
param roleAssignmentEnabled = true
param roleAssignments = [
  {
    definition: '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //owner GUID
    principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' // Update Principal ID
    relativeScope: '/' // Subscription Scope
  }
]
param subscriptionTags = {
    environment: envPrefix
    applicationName: 'SAP Landing Zone'
    owner: 'Platform Team'
    criticality: 'Tier2'
    costCenter: '1234'
    contactEmail: 'test@test.com'
    dataClassification: 'Internal'
    iac: 'Bicep'
}
param hubNetworkResourceId = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-syd-plat-conn-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-plat-conn-10.52.0.0_24' //Update Hub Network Resource ID
param virtualNetworkEnabled = true
param virtualNetworkAddressSpace = [
  '10.52.1.0/24'
]
param virtualNetworkName = '${virtualNetworkPrefix}-${locPrefix}-${lzPrefix}-${envPrefix}-10.52.1.0_24'
param virtualNetworkPeeringEnabled = true
param virtualNetworkResourceGroupName = '${argPrefix}-${locPrefix}-${lzPrefix}-${envPrefix}-network'
param virtualNetworkUseRemoteGateways = false

