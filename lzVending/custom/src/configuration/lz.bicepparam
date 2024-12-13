import * as shared from './shared/shared.conf.bicep'

using '../orchestration/main.bicep'

param existingSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' //Update Subscription ID
param subscriptionMgPlacement = 'mg-alz1-landingzones-corp'
param lzPrefix = 'sap'
param envPrefix = 'sbx'
param roleAssignmentEnabled = true
param roleAssignments = [
  {
    principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' // Update Principal ID
    roleDefinitionIdOrName: 'Reader'
    principalType: 'Group'
    subscriptionId: existingSubscriptionId
  }
  {
    principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' // Update Principal ID
    roleDefinitionIdOrName: 'Owner'
    principalType: 'ServicePrincipal'
    subscriptionId: existingSubscriptionId
  }
]
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
param budgets = [
  {
    name: 'budget-forecasted'
    enabled: true
    startDate: '2025-01-01' // Ensure startDate is updated to the current date if budget is enabled YYYY-MM-DD
    amount: 500
    thresholdType: 'Forecasted'
    thresholds: [
      90
    ]
    contactEmails: [
      'test@outlook.com'
    ]
  }
  {
    name: 'budget-actual'
    enabled: true
    startDate: '2025-01-01' // Ensure startDate is updated to the current date if budget is enabled YYYY-MM-DD
    amount: 500
    thresholdType: 'Actual'
    thresholds: [
      95
      100
    ]
    contactEmails: [
      'test@outlook.com'
    ]
  }
]
param actionGroupEmails = [
  'test@outlook.com'
]
param hubVirtualNetworkResourceId = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-syd-plat-conn-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-plat-conn-10.52.0.0_24' //Update Hub Network Resource ID
param virtualNetworkPeeringEnabled = false
param allowHubVpnGatewayTransit = false
param nextHopIpAddress = '10.1.1.1'
param addressPrefixes = '10.52.1.0/24'
param subnets = [
  {
    name: 'app'
    addressPrefix: '10.52.1.0/27'
    networkSecurityGroupName: '${shared.resPrefixes.networkSecurityGroup}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}${shared.delimeters.dash}app'
    securityRules: []
    routeTableName: '${shared.resPrefixes.routeTable}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}-app'
    routes: []
    serviceEndpoints: []
    serviceEndpointPolicies: []
    delegation: ''
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    name: 'db'
    addressPrefix: '10.52.1.32/27'
    networkSecurityGroupName: '${shared.resPrefixes.networkSecurityGroup}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}-db'
    securityRules: []
    routeTableName: '${shared.resPrefixes.routeTable}${shared.delimeters.dash}${shared.locPrefixes.australiaEast}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}${shared.delimeters.dash}db'
    routes: []
    serviceEndpoints: []
    serviceEndpointPolicies: []
    delegation: ''
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
]
